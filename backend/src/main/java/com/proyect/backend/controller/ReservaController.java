package com.proyect.backend.controller;

import com.proyect.backend.model.Reserva;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;
import com.proyect.backend.service.ReservaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reservas")
@RequiredArgsConstructor
public class ReservaController {

    private final ReservaService reservaService;
    private final UsuarioRepository usuarioRepository;

    /**
     * POST /api/reservas
     *
     * El usuario que hace la reserva se extrae del JWT — cualquier campo
     * "usuario" que venga en el body es ignorado por el servicio.
     */
    @PostMapping
    public ResponseEntity<?> crearReserva(
            @RequestBody Reserva reserva,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Reserva nuevaReserva = reservaService.crearReserva(reserva, username);
            return ResponseEntity.status(HttpStatus.CREATED).body(nuevaReserva);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));

        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", e.getMessage()));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error interno al procesar la reserva."));
        }
    }

    @GetMapping("/recurso/{recursoId}")
    public ResponseEntity<List<Reserva>> obtenerReservasPorRecurso(@PathVariable Long recursoId) {
        return ResponseEntity.ok(reservaService.obtenerReservasPorRecurso(recursoId));
    }

    /**
     * GET /api/reservas/comunidad/{comunidadId}
     *
     * Valida que el comunidadId solicitado coincide con la comunidad
     * del usuario autenticado — evita que un usuario acceda a reservas
     * de otra comunidad cambiando el ID en la URL.
     */
    @GetMapping("/comunidad/{comunidadId}")
    public ResponseEntity<?> obtenerReservasPorComunidad(
            @PathVariable Long comunidadId,
            Authentication authentication) {

        Usuario usuario = usuarioRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));

        if (usuario.getComunidad() == null ||
                !usuario.getComunidad().getId().equals(comunidadId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "No tienes acceso a las reservas de esta comunidad."));
        }

        return ResponseEntity.ok(reservaService.obtenerReservasPorComunidad(comunidadId));
    }
}
