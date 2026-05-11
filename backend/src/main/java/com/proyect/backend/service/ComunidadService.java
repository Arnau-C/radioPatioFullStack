package com.proyect.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComunidadService {

    private final UsuarioRepository usuarioRepository;

    public List<Usuario> obtenerMiembros(Long comunidadId) {
        return usuarioRepository.findByComunidadId(comunidadId);
    }

    @Transactional
    public void expulsarMiembro(Long comunidadId, String usernameExpulsado, String usernamePresidente) {
        // 1. Verificamos que el que hace la petición es el presidente
        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
        // Suponiendo que tu rol se saca así. Ajusta si usas Enums.
        if (!presidente.getRol().equals("PRESIDENTE") && !presidente.getRol().equals("ADMIN")) {
            throw new RuntimeException("Acceso denegado: Solo el presidente puede expulsar miembros.");
        }

        // 2. Buscamos al vecino que vamos a expulsar
        Usuario expulsado = usuarioRepository.findByUsername(usernameExpulsado)
                .orElseThrow(() -> new RuntimeException("Vecino no encontrado"));

        // Comprobamos que realmente está en esa comunidad
        if (expulsado.getComunidad() == null || !expulsado.getComunidad().getId().equals(comunidadId)) {
            throw new RuntimeException("El usuario no pertenece a esta comunidad.");
        }

        // 3. LA MAGIA: Le quitamos la comunidad y le reseteamos el rol
        expulsado.setComunidad(null); 
        expulsado.setRol("USER"); // Para que cuando inicie sesión le salga la pantalla de "No perteneces a ninguna comunidad"

        // 4. Guardamos
        usuarioRepository.save(expulsado);
    }

    @Transactional
    public void actualizarPermisosVecino(Long comunidadId, String usernameVecino, String usernamePresidente, boolean puedeCrearAvisos, boolean puedeGestionarDocumentos) {
        
        // 1. Verificamos que el que hace la petición es el presidente
        Usuario presidente = usuarioRepository.findByUsername(usernamePresidente)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
        if (!presidente.getRol().equals("PRESIDENTE") && !presidente.getRol().equals("ADMIN")) {
            throw new RuntimeException("Acceso denegado: Solo el presidente puede asignar permisos.");
        }

        // 2. Buscamos al vecino al que le vamos a dar los permisos
        Usuario vecino = usuarioRepository.findByUsername(usernameVecino)
                .orElseThrow(() -> new RuntimeException("Vecino no encontrado"));

        // Comprobamos que realmente está en esa comunidad
        if (vecino.getComunidad() == null || !vecino.getComunidad().getId().equals(comunidadId)) {
            throw new RuntimeException("El usuario no pertenece a esta comunidad.");
        }

        // 3. Aplicamos los nuevos permisos
        vecino.setPermisoCrearAvisos(puedeCrearAvisos);
        vecino.setPermisoGestionarDocumentos(puedeGestionarDocumentos);

        // 4. Guardamos los cambios
        usuarioRepository.save(vecino);
    }
}
