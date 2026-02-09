package com.proyect.backend.config;

import com.proyect.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;


//Aquí creamos el PasswordEncoder (que convierte "1234" en "2a10$XyZ...") y el UserDetailsService (que conecta el sistema de seguridad con tu UsuarioRepository).

@Configuration
@RequiredArgsConstructor
public class ApplicationConfig {
    
    private final UsuarioRepository usuarioRepository;

    // EL BUSCADOR
    // Conecta Spring Security con nuestra Base de Datos de Usuarios
    @Bean
    public UserDetailsService userDetailsService() {
        return username -> usuarioRepository.findById(username).orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));
    }

    // EL PROVEEDOR DE AUTENTICACIÓN
    // Este metodo dice: "Usa este UserDetailsService y este PasswordEncoder para autenticar"
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService());
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    // EL JEFE DE AUTENTICACIÓN
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    // EL ENCRIPTADOR (BCrypt)
    // Transforma "password123" en "$2a$10$R7H9..."
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}