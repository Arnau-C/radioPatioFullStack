package com.proyect.backend.service;

import com.proyect.backend.dto.CrearVotacionRequest;
import com.proyect.backend.dto.EmitirVotoRequest;
import com.proyect.backend.dto.OpcionDetalleDTO;
import com.proyect.backend.dto.VotacionDetalleDTO;
import com.proyect.backend.model.*;
import com.proyect.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VotacionService {

    private final VotacionRepository       votacionRepository;
    private final OpcionVotacionRepository  opcionRepository;
    private final VotoRepository           votoRepository;
    private final ComunidadRepository      comunidadRepository;
    private final UsuarioRepository        usuarioRepository;

    // =========================================================================
    // CREAR VOTACIÓN (solo PRESIDENTE de esa comunidad)
    // =========================================================================

    @Transactional
    public VotacionDetalleDTO crearVotacion(Long comunidadId,
                                             CrearVotacionRequest request,
                                             String username) {
        // Validaciones de entrada
        if (request.getTitulo() == null || request.getTitulo().isBlank()) {
            throw new IllegalArgumentException("El título de la votación es obligatorio.");
        }
        if (request.getOpciones() == null || request.getOpciones().size() < 2) {
            throw new IllegalArgumentException("Una votación necesita al menos 2 opciones.");
        }

        Usuario creador = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));

        if (!"PRESIDENTE".equals(creador.getRol())) {
            throw new IllegalStateException("Solo el presidente puede crear votaciones.");
        }

        Comunidad comunidad = comunidadRepository.findById(comunidadId)
                .orElseThrow(() -> new IllegalArgumentException("Comunidad no encontrada."));

        // Verificar que el presidente pertenece a esta comunidad
        if (creador.getComunidad() == null ||
            !comunidad.getId().equals(creador.getComunidad().getId())) {
            throw new IllegalStateException("No eres el presidente de esta comunidad.");
        }

        // Crear la votación
        Votacion votacion = Votacion.builder()
                .titulo(request.getTitulo().trim())
                .descripcion(request.getDescripcion() != null ? request.getDescripcion().trim() : null)
                .estado("ABIERTA")
                .comunidad(comunidad)
                .creador(creador)
                .fechaLimite(request.getFechaLimite())
                .build();
        votacionRepository.save(votacion);

        // Crear las opciones y asociarlas
        for (String textoOpcion : request.getOpciones()) {
            if (textoOpcion == null || textoOpcion.isBlank()) continue;
            OpcionVotacion opcion = OpcionVotacion.builder()
                    .texto(textoOpcion.trim())
                    .votacion(votacion)
                    .build();
            opcionRepository.save(opcion);
        }

        return construirDTO(votacion, username);
    }

    // =========================================================================
    // LISTAR VOTACIONES DE UNA COMUNIDAD
    // =========================================================================

    @Transactional(readOnly = true)
    public List<VotacionDetalleDTO> listarVotaciones(Long comunidadId, String username) {
        return votacionRepository
                .findByComunidadIdOrderByFechaCreacionDesc(comunidadId)
                .stream()
                .map(v -> construirDTO(v, username))
                .collect(Collectors.toList());
    }

    // =========================================================================
    // OBTENER DETALLE — endpoint de polling (se llama cada ~4s desde Flutter)
    // =========================================================================

    @Transactional
    public VotacionDetalleDTO obtenerDetalle(Long votacionId, String username) {
        Votacion votacion = votacionRepository.findById(votacionId)
                .orElseThrow(() -> new IllegalArgumentException("Votación no encontrada."));
        return construirDTO(votacion, username);
    }

    // =========================================================================
    // EMITIR VOTO
    // =========================================================================

    @Transactional
    public VotacionDetalleDTO emitirVoto(Long votacionId,
                                          EmitirVotoRequest request,
                                          String username) {
        Votacion votacion = votacionRepository.findById(votacionId)
                .orElseThrow(() -> new IllegalArgumentException("Votación no encontrada."));

        // Verificar que la votación sigue abierta (también cierra si ha expirado)
        verificarAbierta(votacion);

        // Comprobar que el usuario no ha votado ya
        if (votoRepository.existsByVotacionIdAndUsuarioUsername(votacionId, username)) {
            throw new IllegalStateException("Ya has votado en esta votación.");
        }

        // Verificar que la opción existe y pertenece a esta votación
        OpcionVotacion opcion = opcionRepository.findById(request.getOpcionId())
                .orElseThrow(() -> new IllegalArgumentException("Opción no encontrada."));

        if (!opcion.getVotacion().getId().equals(votacionId)) {
            throw new IllegalArgumentException("La opción no pertenece a esta votación.");
        }

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));

        // Guardar el voto (la constraint única de BD es la última línea de defensa
        // ante condiciones de carrera — DataIntegrityViolationException → 409)
        Voto voto = Voto.builder()
                .opcion(opcion)
                .votacion(votacion)
                .usuario(usuario)
                .build();
        votoRepository.save(voto);

        return construirDTO(votacion, username);
    }

    // =========================================================================
    // CERRAR VOTACIÓN (PRESIDENTE)
    // =========================================================================

    @Transactional
    public VotacionDetalleDTO cerrarVotacion(Long votacionId, String username) {
        Votacion votacion = votacionRepository.findById(votacionId)
                .orElseThrow(() -> new IllegalArgumentException("Votación no encontrada."));

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));

        if (!"PRESIDENTE".equals(usuario.getRol())) {
            throw new IllegalStateException("Solo el presidente puede cerrar una votación.");
        }

        if (!votacion.getComunidad().getId().equals(usuario.getComunidad().getId())) {
            throw new IllegalStateException("No tienes permisos sobre esta votación.");
        }

        if ("CERRADA".equals(votacion.getEstado())) {
            throw new IllegalStateException("La votación ya está cerrada.");
        }

        votacion.setEstado("CERRADA");
        votacionRepository.save(votacion);

        return construirDTO(votacion, username);
    }

    // =========================================================================
    // HELPER PRIVADO — construye el DTO con conteos y estado del usuario
    // =========================================================================

    private VotacionDetalleDTO construirDTO(Votacion votacion, String username) {
        // Auto-cierre si ha superado la fecha límite
        if (votacion.getFechaLimite() != null
                && LocalDateTime.now().isAfter(votacion.getFechaLimite())
                && "ABIERTA".equals(votacion.getEstado())) {
            votacion.setEstado("CERRADA");
            votacionRepository.save(votacion);
        }

        // ¿Ha votado ya este usuario?
        boolean yaVotado = votoRepository
                .existsByVotacionIdAndUsuarioUsername(votacion.getId(), username);

        Long opcionVotadaId = null;
        if (yaVotado) {
            opcionVotadaId = votoRepository
                    .findByVotacionIdAndUsuarioUsername(votacion.getId(), username)
                    .map(v -> v.getOpcion().getId())
                    .orElse(null);
        }

        // Conteos por opción
        List<OpcionVotacion> opciones = opcionRepository.findByVotacionId(votacion.getId());
        long totalVotos = opciones.stream()
                .mapToLong(o -> votoRepository.countByOpcionId(o.getId()))
                .sum();

        List<OpcionDetalleDTO> opcionesDTO = opciones.stream()
                .map(o -> {
                    long votos = votoRepository.countByOpcionId(o.getId());
                    double pct = totalVotos > 0 ? (double) votos / totalVotos * 100.0 : 0.0;
                    // Redondear a 1 decimal
                    double porcentaje = Math.round(pct * 10.0) / 10.0;
                    return OpcionDetalleDTO.builder()
                            .id(o.getId())
                            .texto(o.getTexto())
                            .votos(votos)
                            .porcentaje(porcentaje)
                            .build();
                })
                .collect(Collectors.toList());

        return VotacionDetalleDTO.builder()
                .id(votacion.getId())
                .titulo(votacion.getTitulo())
                .descripcion(votacion.getDescripcion())
                .estado(votacion.getEstado())
                .creadorUsername(votacion.getCreador().getUsername())
                .fechaCreacion(votacion.getFechaCreacion())
                .fechaLimite(votacion.getFechaLimite())
                .yaVotado(yaVotado)
                .opcionVotadaId(opcionVotadaId)
                .totalVotos((int) totalVotos)
                .opciones(opcionesDTO)
                .build();
    }

    // Verifica que la votación está abierta; si tiene fechaLimite expirada la cierra.
    private void verificarAbierta(Votacion votacion) {
        if (votacion.getFechaLimite() != null
                && LocalDateTime.now().isAfter(votacion.getFechaLimite())) {
            votacion.setEstado("CERRADA");
            votacionRepository.save(votacion);
        }
        if ("CERRADA".equals(votacion.getEstado())) {
            throw new IllegalStateException("Esta votación ya está cerrada.");
        }
    }
}
