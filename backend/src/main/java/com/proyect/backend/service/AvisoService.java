package com.proyect.backend.service;

import com.proyect.backend.model.Aviso;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.AvisoRepository;
import com.proyect.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AvisoService {

    private final AvisoRepository avisoRepository;
    private final UsuarioRepository usuarioRepository;

    // Obtiene los avisos de una fecha
    public List<Aviso> obtenerAvisosPorFecha(LocalDate fecha) {
        return avisoRepository.findAllByFechaAvisoOrderByIdDesc(fecha);
    }

    // Crea un nuevo aviso. Solo debería llamarse si el usuario es PRESIDENTE (chequeo en controlador)
    public Aviso crearAviso(String titulo, String descripcion, LocalDate fecha, String usernameCreador) {
        Usuario creador = usuarioRepository.findByUsername(usernameCreador)
                .orElseThrow(() -> new RuntimeException("Usuario creador no encontrado"));

        Aviso nuevoAviso = Aviso.builder()
                .titulo(titulo)
                .descripcion(descripcion)
                .fechaAviso(fecha)
                .creador(creador)
                .build();

        return avisoRepository.save(nuevoAviso);
    }
}