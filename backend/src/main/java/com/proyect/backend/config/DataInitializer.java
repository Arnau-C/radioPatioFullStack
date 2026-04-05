package com.proyect.backend.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.proyect.backend.model.Foro;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.model.Comunidad;
import com.proyect.backend.repository.UsuarioRepository;
import com.proyect.backend.repository.ForoRepository;
import com.proyect.backend.repository.ComunidadRepository;

import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final ForoRepository foroRepository;
    private final ComunidadRepository comunidadRepository;

    @Override
    public void run(String... args) throws Exception {
        // 1. CREAR EL SUPERADMIN (Solo si no existe)
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
            System.out.println("✅ SUPER ADMIN LISTO");
        }
        
        // 2. CREAR COMUNIDAD DE SOPORTE (Necesaria para el foro)
        // Buscamos si hay alguna comunidad, si no hay ninguna, creamos la de soporte
        if (comunidadRepository.count() == 0) {
            Comunidad soporte = Comunidad.builder()
                    .nombre("Soporte Radio Patio")
                    .direccion("Sede Central")
                    .codigoInvitacion("SOPORTE123")
                    .fechaCreacion(LocalDateTime.now())
                    .build();
            comunidadRepository.save(soporte);
            System.out.println("✅ COMUNIDAD DE SOPORTE CREADA");
        }

        // 3. CREAR EL FORO DE SUGERENCIAS (Solo si no hay foros)
        // NO PONEMOS ID MANUAL. Al ser la primera inserción, la BD le dará el ID 1 automáticamente.
        if (foroRepository.count() == 0) {
            Comunidad comunidadSoporte = comunidadRepository.findAll().get(0);
            
            Foro foroSugerencias = Foro.builder()
                    .titulo("Foro de Sugerencias Global")
                    .descripcion("Espacio para contactar con los desarrolladores")
                    .comunidad(comunidadSoporte) // <--- VINCULACIÓN OBLIGATORIA
                    .fechaCreacion(LocalDateTime.now())
                    .build();
            
            foroRepository.save(foroSugerencias);
            System.out.println("✅ FORO DE SUGERENCIAS CREADO CORRECTAMENTE");
        }
    }
}