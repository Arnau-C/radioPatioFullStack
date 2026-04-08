package com.proyect.backend.service;

import com.proyect.backend.dto.AuthResponse;
import com.proyect.backend.dto.LoginRequest;
import com.proyect.backend.dto.RegisterRequest;
import com.proyect.backend.model.Foro;
import com.proyect.backend.model.LoginLog; // <--- NUEVO IMPORT
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ForoRepository;
import com.proyect.backend.repository.LoginLogRepository; // <--- NUEVO IMPORT
import com.proyect.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

import javax.management.relation.RoleList;

@Service
@RequiredArgsConstructor
// Servicio de Autenticación con Lógica de Bloqueo y Auditoría de Logs
public class AuthService {

    private final UserDetailsService userDetailsService;
    
    private final UsuarioRepository repository;
    private final LoginLogRepository loginLogRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
private final ForoRepository foroRepository;
    // Metódos del servicio, incluyendo registro, login, eliminación y actualización de usuarios

    // MÉTODO DE REGISTRO DE USUARIO
    public AuthResponse register(RegisterRequest request) {
        if(repository.existsByUsername(request.getUsername())){
            throw new IllegalArgumentException("El nombre de usuario ya existe");
        }
        if(repository.existsByEmail(request.getEmail())){
            throw new IllegalArgumentException("El email ya está registrado");
        }

        var user = Usuario.builder()
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .email(request.getEmail())
                .nombre(request.getNombre())
                .apellidos(request.getApellidos())
                .rol("USER")
                .cuentaBloqueada(false)
                .intentosFallidos(0)
                .build();

        repository.save(user);

        var jwtToken = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(jwtToken)
                .username(user.getUsername())
                .nombre(user.getNombre())
                .apellidos(user.getApellidos())
                .email(user.getEmail())
                .rol(user.getRol())
                .build();
    }

    public void registerByAdmin(RegisterRequest request){
        if (repository.findByUsername(request.getUsername()).isPresent()) {
        throw new IllegalArgumentException("El nombre de usuario ya existe");
        }
        String rolAsignado = request.getRol();
        Usuario user = Usuario.builder()
            .username(request.getUsername())
            .password(passwordEncoder.encode(request.getPassword()))
            .nombre(request.getNombre())
            .apellidos(request.getApellidos())
            .email(request.getEmail())
            .rol(rolAsignado)
            .cuentaBloqueada(false)
            .intentosFallidos(0)
            .build();

        repository.save(user);
    }


    // MÉTODO DE LOGIN (CON AUDITORÍA DE LOGS)
    public AuthResponse login(LoginRequest request){
        
        // Detectamos el sistema (si viene null, ponemos 'Desconocido')
        String sistema = (request.getSistema() != null) ? request.getSistema() : "Desconocido";

        // Buscamos el usuario
        // Nota: Si no existe, lanza excepción y NO se guarda log (porque tu tabla log requiere un Usuario real)
        Usuario user = repository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        // CHECK: ¿Está bloqueado PREVIAMENTE?
        if (user.isCuentaBloqueada()) {
            // [LOG] Registramos el intento fallido por bloqueo
            registrarLog(user, sistema, false, "Cuenta bloqueada previamente");
            
            throw new IllegalArgumentException("Tu cuenta está bloqueada. Contacta con un administrador.");
        }

        try {
            // INTENTO: Probamos la autenticación
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsername(),
                            request.getPassword()
                    )
            );
            
            // SI LLEGA AQUÍ, LA CONTRASEÑA ES CORRECTA (ÉXITO)
            
            // RESET: Si entra bien, ponemos el contador a 0
            if (user.getIntentosFallidos() > 0) {
                user.setIntentosFallidos(0);
                repository.save(user);
            }

            // [LOG] Registramos el éxito
            registrarLog(user, sistema, true, null);
            Long foroId = null;
            if (user.getComunidad() != null) {
                foroId = foroRepository.findByComunidadId(user.getComunidad().getId())
                        .map(Foro::getId)
                        .orElse(null);
            }

            // 2. Generamos Token

            // Generamos Token
            var jwtToken = jwtService.generateToken(user);

            return AuthResponse.builder()
                    .token(jwtToken)
                    .username(user.getUsername())
                    .nombre(user.getNombre())
                    .apellidos(user.getApellidos())
                    .email(user.getEmail())
                    .rol(user.getRol())
                    .foroId(foroId)
                    .build();

        } catch (BadCredentialsException e) {
            // SI ENTRA AQUÍ, LA CONTRASEÑA ES INCORRECTA (FALLO) 
            
            // LOGICA DE BLOQUEO
            int nuevosIntentos = user.getIntentosFallidos() + 1;
            user.setIntentosFallidos(nuevosIntentos);
            
            String mensajeErrorFrontend;
            String motivoLog = "Contraseña incorrecta"; // Motivo por defecto para el log

            if (nuevosIntentos >= 3) {
                // Bloqueamos
                user.setCuentaBloqueada(true);
                mensajeErrorFrontend = "Has superado los 3 intentos. Tu cuenta ha sido bloqueada.";
                motivoLog = "Bloqueado tras 3 intentos fallidos"; // Motivo específico para el log
            } else {
                // Avisamos
                int intentosRestantes = 3 - nuevosIntentos;
                mensajeErrorFrontend = "Credenciales incorrectas. Te quedan " + intentosRestantes + " intentos.";
            }
            
            // Guardamos los cambios del usuario (intentos/bloqueo)
            repository.save(user);

            // [LOG] Registramos el fallo y el motivo exacto
            registrarLog(user, sistema, false, motivoLog);
            
            // Lanzamos el error para que llegue al Frontend
            throw new IllegalArgumentException(mensajeErrorFrontend);
        }
    }

    // MÉTODO AUXILIAR PRIVADO PARA GUARDAR LOGS
    private void registrarLog(Usuario usuario, String sistema, boolean exito, String motivo) {
        LoginLog log = new LoginLog();
        log.setUsuario(usuario);
        log.setUsernameTexto(usuario.getUsername());
        log.setFechaHora(LocalDateTime.now());
        log.setSistemaOrigen(sistema);
        log.setExito(exito);
        log.setMotivoFallo(motivo); // Si es éxito, el motivo será null, lo cual es correcto

        loginLogRepository.save(log);
    }

    // ELIMINAR USUARIO
    public void eliminarUsuario(String username) {
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("No se puede borrar: El usuario no existe"));
        
        // Antes de borrar el usuario, actualizamos sus logs para desvincular el objeto Usuario
        if (user.getLogs() != null) {
            for (LoginLog log : user.getLogs()) {
                log.setUsuario(null); // Rompemos el enlace al objeto User
                loginLogRepository.save(log); // Guardamos el cambio en el log
            }
        }
        
        // Ahora sí borramos el usuario
        repository.delete(user);
    }

    // ACTUALIZAR USUARIO
    public Usuario actualizarUsuario(String username, RegisterRequest request) {
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado para editar"));

        if (request.getNombre() != null) user.setNombre(request.getNombre());
        if (request.getApellidos() != null) user.setApellidos(request.getApellidos());
        if (request.getEmail() != null) user.setEmail(request.getEmail());

        return repository.save(user);
    }
}