package com.proyect.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.proyect.backend.dto.IncidenciaRequest;
import com.proyect.backend.model.Comunidad;
import com.proyect.backend.model.Incidencia;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ComunidadRepository;
import com.proyect.backend.repository.IncidenciaRepository;
import com.proyect.backend.repository.UsuarioRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class IncidenciaService {
    private final IncidenciaRepository incidenciaRepository;
    private final ComunidadRepository comunidadRepository;
    private final UsuarioRepository usuarioRepository;

public Incidencia crearIncidencia(Long comunidadId, IncidenciaRequest request, String username) {
        // 1. Buscamos al usuario creador (su nombre nos llega gracias al Token)
        Usuario creador = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        // 2. Buscamos la comunidad donde se reporta
        Comunidad comunidad = comunidadRepository.findById(comunidadId)
                .orElseThrow(() -> new RuntimeException("Comunidad no encontrada"));

        // 3. Creamos la incidencia con el Builder que hizo Oscar
        Incidencia incidencia = Incidencia.builder()
                .titulo(request.getTitulo())
                .descripcion(request.getDescripcion())
                .estado("PENDIENTE") // Valor por defecto
                .creador(creador)
                .comunidad(comunidad)
                // Nota: fechaCreacion se pone sola gracias a @PrePersist en tu modelo
                .build();

        // 4. Guardamos en la Base de Datos
        return incidenciaRepository.save(incidencia);
    }

    public List<Incidencia> obtenerIncidenciasPendientes(Long comunidadId) {
        return incidenciaRepository.findByComunidadIdAndEstadoNot(comunidadId, "RESUELTA");
    }

    @Transactional
    public void resolverIncidencia(Long comunidadId, Long incidenciaId, String username) {

        Usuario usuarioLogueado = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
        String rol = usuarioLogueado.getRol().toString(); 
        
        if (!rol.equals("PRESIDENTE") && !rol.equals("ADMIN") && !rol.equals("SUPER_ADMIN")) {
            throw new RuntimeException("Acceso denegado: Solo el presidente puede resolver incidencias.");
        }
        Incidencia incidencia = incidenciaRepository.findById(incidenciaId)
                .orElseThrow(() -> new RuntimeException("Incidencia no encontrada con ID: " + incidenciaId));
        
        // Verificamos que la incidencia corresponda a la comunidad desde la que se llama
        if (!incidencia.getComunidad().getId().equals(comunidadId)) {
            throw new RuntimeException("Acceso denegado: Esta incidencia no pertenece a la comunidad indicada.");
        }

        incidencia.setEstado("RESUELTA");

        incidenciaRepository.save(incidencia);
    }
}
