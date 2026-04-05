package com.proyect.backend.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.proyect.backend.model.Foro;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.model.Comunidad; // Importante
import com.proyect.backend.repository.UsuarioRepository;
import com.proyect.backend.repository.ForoRepository;
import com.proyect.backend.repository.ComunidadRepository; // Añadido

import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final ForoRepository foroRepository;
    private final ComunidadRepository comunidadRepository; // Inyectamos esto

    @Override
    public void run(String... args) throws Exception {
        // 1. CREAR SUPERADMIN
        if (!repository.existsByUsername("superadmin")) {
            Usuario superAdmin = Usuario.builder()
                    .username("superadmin")
                    .password(passwordEncoder.encode("admin1234")) 
                    .nombre("Super")
                    .apellidos("Administrador")
                    .email("admin@radiopatio.com")
                    .rol("SUPER_ADMIN")
                    .build();
            repository.save(superAdmin);
            System.out.println("SUPER ADMIN CREADO");
        }

        // 2. CREAR COMUNIDAD DE SISTEMA (Para que el foro no sea huérfano)
        // Usamos el ID 1 o un nombre clave
        Comunidad comunidadSistema;
        if (!comunidadRepository.existsById(1L)) {
            comunidadSistema = Comunidad.builder()
                    .id(1L)
                    .nombre("Soporte Radio Patio")
                    .direccion("Nube de Desarrollo")
                    .codigoInvitacion("SOPORTE123")
                    .build();
            comunidadRepository.save(comunidadSistema);
        } else {
            comunidadSistema = comunidadRepository.findById(1L).get();
        }

        // 3. CREAR FORO GLOBAL vinculado a esa comunidad
        if (!foroRepository.existsById(1L)) {
            Foro foroSugerencias = Foro.builder()
                    .id(1L)
                    .titulo("Foro de Sugerencias Global")
                    .descripcion("Espacio para que los vecinos contacten con los desarrolladores")
                    .comunidad(comunidadSistema) // <--- ESTO ES LO QUE FALTABA
                    .fechaCreacion(LocalDateTime.now())
                    .build();
            
            foroRepository.save(foroSugerencias);
            System.out.println("FORO DE SUGERENCIAS CREADO Y VINCULADO");
        }
    }
}