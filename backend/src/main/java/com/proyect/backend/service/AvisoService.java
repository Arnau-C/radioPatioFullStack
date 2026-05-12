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

    // --- NUEVO MÉTODO DE SEGURIDAD PARA AVISOS ---
    private void validarPermisosAvisos(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        // Verificamos si es Presidente o si tiene el permiso de gestión activado
        boolean esPresidente = "PRESIDENTE".equals(usuario.getRol());
        boolean tienePermiso = usuario.isPermisoGestionarReservas(); // Ajusta al nombre de tu booleano de permisos

        if (!esPresidente && !tienePermiso) {
            throw new RuntimeException("Acceso denegado: No tienes permisos para publicar avisos en la comunidad.");
        }
    }

    // Crea un nuevo aviso validando permisos internamente
    public Aviso crearAviso(String titulo, String descripcion, LocalDate fecha, String usernameCreador) {
        
        // 1. Validamos que el autor tenga permiso antes de hacer nada
        validarPermisosAvisos(usernameCreador);

        Usuario creador = usuarioRepository.findByUsername(usernameCreador)
                .orElseThrow(() -> new RuntimeException("Usuario creador no encontrado"));

        // 2. Construimos el aviso
        Aviso nuevoAviso = Aviso.builder()
                .titulo(titulo)
                .descripcion(descripcion)
                .fechaAviso(fecha)
                .creador(creador)
                .build();

        return avisoRepository.save(nuevoAviso);
    }
}