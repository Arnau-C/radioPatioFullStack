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


// Esta clase es el Cerebro de la Autenticación: maneja el registro y login de usuarios.

@Service
@RequiredArgsConstructor
public class AuthService{
    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    
    // --- MÉTODO DE REGISTRO (COCINAR UN USUARIO NUEVO) ---
    public AuthResponse register(RegisterRequest request) {
        
        if(repository.existsByUsername(request.getUsername())){
            throw new IllegalArgumentException("El nombre de usuario ya existe");
        }
        if(repository.existsByEmail(request.getEmail())){
            throw new IllegalArgumentException("El email ya está registrado");
        }
        var user = Usuario.builder()
            .username(request.getUsername())
            .password(passwordEncoder.encode(request.getPassword())) // ¡IMPORTANTE! Encriptamos la contraseña aquí
            .email(request.getEmail())
            .nombre(request.getNombre())
            .apellidos(request.getApellidos())
            .rol("USER") // Asignamos el rol por defecto. El usuario no lo elige.
            .cuentaBloqueada(false)
            .intentosFallidos(0)
            .build();

        repository.save(user);

        var jwtToken = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(jwtToken)
                .build();
    }
    
    public AuthResponse login(LoginRequest request){
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        Usuario user = repository.findByUsername(request.getUsername()).orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));
        
        // 3. Generamos un nuevo Token fresco para él
        var jwtToken = jwtService.generateToken(user);

        // 4. Se lo devolvemos
        return AuthResponse.builder()
                .token(jwtToken)
                .build();
    }
    // --- 3. ELIMINAR USUARIO (Fusión) ---
    public void eliminarUsuario(String username) {
        if (!repository.existsByUsername(username)) { 
             // Usamos RuntimeException genérica
             throw new RuntimeException("No se puede borrar: El usuario no existe");
        }
        repository.deleteById(username); 
    }

    // --- 4. ACTUALIZAR USUARIO (Fusión) ---
    public Usuario actualizarUsuario(String username, RegisterRequest request) {
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado para editar"));

        user.setNombre(request.getNombre());
        user.setApellidos(request.getApellidos());
        user.setEmail(request.getEmail());

        return repository.save(user);
    }
}