package com.proyect.backend.service;

import com.proyect.backend.dto.AuthResponse;
import com.proyect.backend.dto.LoginRequest;
import com.proyect.backend.dto.RegisterRequest;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    
    // --- MÉTODO DE REGISTRO ---
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

        // 👇 AQUI ESTÁ EL CAMBIO: Devolvemos todos los datos, no solo el token
        return AuthResponse.builder()
                .token(jwtToken)
                .username(user.getUsername()) // <--- AÑADIDO
                .nombre(user.getNombre())     // <--- AÑADIDO
                .apellidos(user.getApellidos()) // <--- AÑADIDO
                .email(user.getEmail())       // <--- AÑADIDO
                .rol(user.getRol())           // <--- AÑADIDO
                .build();
    }
    
    // --- MÉTODO DE LOGIN ---
    public AuthResponse login(LoginRequest request){
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        Usuario user = repository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));
        
        var jwtToken = jwtService.generateToken(user);

        // 👇 AQUI ESTÁ EL CAMBIO: Rellenamos los datos para Flutter
        return AuthResponse.builder()
                .token(jwtToken)
                .username(user.getUsername()) // <--- AÑADIDO
                .nombre(user.getNombre())     // <--- AÑADIDO
                .apellidos(user.getApellidos()) // <--- AÑADIDO
                .email(user.getEmail())       // <--- AÑADIDO
                .rol(user.getRol())           // <--- AÑADIDO
                .build();
    }

    // --- 3. ELIMINAR USUARIO (Versión Puente: String -> ID) ---
    public void eliminarUsuario(String username) {
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("No se puede borrar: El usuario no existe"));
        
        repository.delete(user);
    }

    // --- 4. ACTUALIZAR USUARIO ---
    // Nota: Aquí lo ideal sería usar UpdateUserRequest, pero si usas RegisterRequest funciona igual
    public Usuario actualizarUsuario(String username, RegisterRequest request) {
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado para editar"));

        if (request.getNombre() != null) user.setNombre(request.getNombre());
        if (request.getApellidos() != null) user.setApellidos(request.getApellidos());
        if (request.getEmail() != null) user.setEmail(request.getEmail());

        return repository.save(user);
    }
}