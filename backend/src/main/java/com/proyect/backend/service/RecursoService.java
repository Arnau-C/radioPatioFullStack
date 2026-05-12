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
        Usuario usuario = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        Comunidad comunidad = comunidadRepository.findById(comunidadId)
                .orElseThrow(() -> new IllegalArgumentException("Comunidad no encontrada"));

        // LÓGICA DE PERMISOS
        boolean esPresidente = "PRESIDENTE".equals(usuario.getRol());
        boolean tienePermiso = usuario.isPermisoGestionarReservas(); 

        if (!(esPresidente || tienePermiso) || !comunidad.getId().equals(usuario.getComunidad().getId())) {
            throw new IllegalStateException("No tienes permisos para crear recursos en esta comunidad.");
        }

        nuevoRecurso.setComunidad(comunidad);
        
        // 👇 AQUÍ ESTÁ EL ARREGLO: Usamos el nuevo sistema de horas 👇
        if (nuevoRecurso.getMaxHorasReserva() == null) {
            nuevoRecurso.setMaxHorasReserva(2); // Le damos 2 horas por defecto si viene vacío
        }

        return recursoRepository.save(nuevoRecurso);
    }

    public List<Recurso> obtenerRecursosComunidad(Long comunidadId) {
        return recursoRepository.findByComunidadId(comunidadId);
    }

    public void eliminarRecurso(Long recursoId, String usernamePresidente) {
        Recurso recurso = recursoRepository.findById(recursoId)
                .orElseThrow(() -> new IllegalArgumentException("Recurso no encontrado"));
                
        Usuario usuario = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
                
        boolean esPresidente = "PRESIDENTE".equals(usuario.getRol());
        boolean tienePermiso = usuario.isPermisoGestionarReservas();

        if (!(esPresidente || tienePermiso) || !recurso.getComunidad().getId().equals(usuario.getComunidad().getId())) {
            throw new IllegalStateException("No tienes permisos para eliminar recursos en esta comunidad.");
        }

        recursoRepository.delete(recurso);
    }
}