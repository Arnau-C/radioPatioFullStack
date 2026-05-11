package com.proyect.backend.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.proyect.backend.model.*;
import com.proyect.backend.repository.*;

import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final ForoRepository foroRepository;
    private final ComunidadRepository comunidadRepository;

    @Override
    public void run(String... args) throws Exception {
        // 1. Superadmin
        if (!repository.existsByUsername("superadmin")) {
            repository.save(Usuario.builder()
                    .username("superadmin")
                    .password(passwordEncoder.encode("admin1234"))
                    .nombre("Super").apellidos("Admin").email("admin@radiopatio.com")
                    .rol("SUPER_ADMIN").build());
        }

        // 2. Comunidad de Gavà (La primera del sistema)
        Comunidad gava;
        if (comunidadRepository.count() == 0) {
            gava = comunidadRepository.save(Comunidad.builder()
                    .nombre("Comunidad Gavà Centro")
                    .direccion("Calle Mayor, 1")
                    .codigoInvitacion("GAVA001")
                    .fechaCreacion(LocalDateTime.now())
                    .build());
            System.out.println("✅ Comunidad Gavà creada");
        } else {
            gava = comunidadRepository.findAll().get(0);
        }

        // 3. Foro de la Comunidad (VINCULADO A LA COMUNIDAD)
        if (foroRepository.count() == 0) {
            foroRepository.save(Foro.builder()
                    .titulo("Foro de Vecinos")
                    .descripcion("Espacio para hablar de la comunidad de Gavà")
                    .comunidad(gava)
                    .fechaCreacion(LocalDateTime.now())
                    .build());
            System.out.println("✅ Foro de Comunidad creado");
        }

        // 4. Asegurar que TODAS las comunidades tengan su foro vinculado
        List<Comunidad> todas = comunidadRepository.findAll();
        for (Comunidad com : todas) {
            boolean tieneForo = foroRepository.findByComunidadId(com.getId()).isPresent();
            
            if (!tieneForo) {
                foroRepository.save(Foro.builder()
                        .titulo("Foro de " + com.getNombre())
                        .descripcion("Chat comunitario")
                        .comunidad(com) // <--- Aquí creamos el vínculo que falta
                        .fechaCreacion(LocalDateTime.now())
                        .build());
                System.out.println("✅ Foro recuperado para la comunidad: " + com.getNombre());
            }
        }
    }
}