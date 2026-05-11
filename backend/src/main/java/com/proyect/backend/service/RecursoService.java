package com.proyect.backend.service;

import com.proyect.backend.model.Comunidad;
import com.proyect.backend.model.Recurso;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ComunidadRepository;
import com.proyect.backend.repository.RecursoRepository;
import com.proyect.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RecursoService {

    @Autowired
    private RecursoRepository recursoRepository;

    @Autowired
    private ComunidadRepository comunidadRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public Recurso crearRecurso(Recurso nuevoRecurso, Long comunidadId, String usernamePresidente) {
        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Presidente no encontrado"));

        Comunidad comunidad = comunidadRepository.findById(comunidadId)
                .orElseThrow(() -> new IllegalArgumentException("Comunidad no encontrada"));

        // Validar permisos
        if (!"PRESIDENTE".equals(presidente.getRol()) || !comunidad.getId().equals(presidente.getComunidad().getId())) {
            throw new IllegalStateException("No tienes permisos para crear recursos en esta comunidad.");
        }

        nuevoRecurso.setComunidad(comunidad);
        if (nuevoRecurso.getTipoReserva() == null) {
            nuevoRecurso.setTipoReserva("POR_HORAS");
        }

        return recursoRepository.save(nuevoRecurso);
    }

    public List<Recurso> obtenerRecursosComunidad(Long comunidadId) {
        return recursoRepository.findByComunidadId(comunidadId);
    }

    public void eliminarRecurso(Long recursoId, String usernamePresidente) {
        Recurso recurso = recursoRepository.findById(recursoId)
                .orElseThrow(() -> new IllegalArgumentException("Recurso no encontrado"));
                
        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Presidente no encontrado"));

        if (!"PRESIDENTE".equals(presidente.getRol()) || !recurso.getComunidad().getId().equals(presidente.getComunidad().getId())) {
            throw new IllegalStateException("No tienes permisos para eliminar recursos en esta comunidad.");
        }

        recursoRepository.delete(recurso);
    }
}
