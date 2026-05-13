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

    /**
     * Devuelve los avisos de una fecha filtrando por la comunidad del usuario autenticado.
     * Si el usuario no pertenece a ninguna comunidad, devuelve lista vacía.
     *
     * @param fecha    Día del que se quieren los avisos.
     * @param username Username del usuario autenticado (extraído del JWT, nunca del body).
     */
    public List<Aviso> obtenerAvisosPorFecha(LocalDate fecha, String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));

        // Sin comunidad asignada → no hay avisos que mostrar
        if (usuario.getComunidad() == null) {
            return List.of();
        }

        return avisoRepository.findByComunidadIdAndFechaAviso(
                usuario.getComunidad().getId(), fecha);
    }

    /**
     * Crea un nuevo aviso vinculado a la comunidad del creador.
     * El usernameCreador viene del JWT (no del body de la petición).
     */
    public Aviso crearAviso(String titulo, String descripcion, LocalDate fecha, String usernameCreador) {
        Usuario creador = usuarioRepository.findByUsername(usernameCreador)
                .orElseThrow(() -> new IllegalArgumentException("Usuario creador no encontrado."));

        if (creador.getComunidad() == null) {
            throw new IllegalStateException("El usuario no pertenece a ninguna comunidad.");
        }

        Aviso nuevoAviso = Aviso.builder()
                .titulo(titulo)
                .descripcion(descripcion)
                .fechaAviso(fecha)
                .creador(creador)
                .build();

        return avisoRepository.save(nuevoAviso);
    }
}