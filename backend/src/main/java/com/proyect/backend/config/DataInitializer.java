package com.proyect.backend.config;


import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;

import lombok.RequiredArgsConstructor;

// Clase para inicializar datos al arrancar la aplicación (crear un superadmin si no existe)
@Component
@RequiredArgsConstructor
public class DataInitializer implements  CommandLineRunner{

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Si no existe el superadmin, lo creamos
        if (!repository.existsByUsername("superadmin")) {
            
            Usuario superAdmin = Usuario.builder()
                    .username("superadmin")
                    .password(passwordEncoder.encode("admin1234")) 
                    .nombre("Super")
                    .apellidos("Administrador")
                    .email("admin@radiopatio.com")
                    .rol("SUPER_ADMIN") // <--- EL ROL IMPORTANTE
                    .cuentaBloqueada(false)
                    .intentosFallidos(0)
                    .build();

            repository.save(superAdmin);
            System.out.println("SUPER ADMIN CREADO: User: superadmin | Pass: admin1234");
        }
    }
}
