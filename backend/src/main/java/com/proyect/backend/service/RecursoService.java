package com.proyect.backend.service;

import com.proyect.backend.model.Comunidad;
import com.proyect.backend.model.Recurso;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ComunidadRepository;
import com.proyect.backend.repository.RecursoRepository;
import com.proyect.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class RecursoService {

    @Autowired
    private RecursoRepository recursoRepository;

    @Autowired
    private ComunidadRepository comunidadRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Transactional
    public Recurso crearRecurso(Recurso nuevoRecurso, Long comunidadId, String usernamePresidente) {
        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Presidente no encontrado"));

        Comunidad comunidad = comunidadRepository.findById(comunidadId)
                .orElseThrow(() -> new IllegalArgumentException("Comunidad no encontrada"));

        // Validar que el usuario tenga el rol correcto
        if (!"PRESIDENTE".equals(presidente.getRol())) {
            throw new IllegalStateException("No tienes permisos para crear recursos en esta comunidad.");
        }

        // Validar que el presidente pertenece a esta comunidad
        // (getComunidad() puede ser null si el usuario fue creado sin comunidad asignada)
        Comunidad comunidadPresidente = presidente.getComunidad();
        if (comunidadPresidente == null || !comunidad.getId().equals(comunidadPresidente.getId())) {
            throw new IllegalStateException("No estás asignado como presidente de esta comunidad.");
        }

        nuevoRecurso.setComunidad(comunidad);
        if (nuevoRecurso.getTipoReserva() == null) {
            nuevoRecurso.setTipoReserva("POR_HORAS");
        }
        if (nuevoRecurso.getMaxHorasReserva() == null) {
            nuevoRecurso.setMaxHorasReserva(2);
        }

        return recursoRepository.save(nuevoRecurso);
    }

    public List<Recurso> obtenerRecursosComunidad(Long comunidadId) {
        return recursoRepository.findByComunidadId(comunidadId);
    }

    @Transactional
    public void eliminarRecurso(Long recursoId, String usernamePresidente) {
        Recurso recurso = recursoRepository.findById(recursoId)
                .orElseThrow(() -> new IllegalArgumentException("Recurso no encontrado"));

        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Presidente no encontrado"));

        if (!"PRESIDENTE".equals(presidente.getRol())) {
            throw new IllegalStateException("No tienes permisos para eliminar recursos en esta comunidad.");
        }

        Comunidad comunidadPresidente = presidente.getComunidad();
        if (comunidadPresidente == null || !recurso.getComunidad().getId().equals(comunidadPresidente.getId())) {
            throw new IllegalStateException("No estás asignado como presidente de esta comunidad.");
        }

        recursoRepository.delete(recurso);
    }
}
