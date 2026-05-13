package com.proyect.backend.controller;

import com.proyect.backend.dto.AvisoDTO;
import com.proyect.backend.model.Aviso;
import com.proyect.backend.service.AvisoService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/avisos")
@RequiredArgsConstructor
public class AvisoController {

    private final AvisoService avisoService;

    /**
     * GET /api/avisos?fecha=2024-03-24
     *
     * Devuelve los avisos del día para la comunidad del usuario autenticado.
     * La comunidad se determina a partir del JWT — el cliente nunca puede inyectar
     * un comunidadId arbitrario.
     */
    @GetMapping
    public ResponseEntity<List<AvisoDTO>> obtenerAvisos(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha,
            Authentication authentication) {

        // El username sale del JWT, nunca del body.
        String username = authentication.getName();

        List<AvisoDTO> lista = avisoService.obtenerAvisosPorFecha(fecha, username).stream()
                .map(aviso -> AvisoDTO.builder()
                        .id(aviso.getId())
                        .titulo(aviso.getTitulo())
                        .descripcion(aviso.getDescripcion())
                        .fechaAviso(aviso.getFechaAviso())
                        .creadorUsername(aviso.getCreador().getUsername())
                        .build())
                .toList();

        return ResponseEntity.ok(lista);
    }

    /**
     * POST /api/avisos — Crea un aviso (solo PRESIDENTE).
     *
     * El creador se extrae del JWT, ignorando cualquier "usernameCreador"
     * que pueda venir en el body (campo mantenido por compatibilidad con
     * clientes Flutter existentes, pero descartado en el servidor).
     */
    @PostMapping
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> crearAviso(
            @RequestBody Map<String, Object> payload,
            Authentication authentication) {
        try {
            String titulo      = (String) payload.get("titulo");
            String descripcion = (String) payload.get("descripcion");
            String fechaStr    = (String) payload.get("fecha");
            LocalDate fecha    = LocalDate.parse(fechaStr);

            if (titulo == null || titulo.isBlank() ||
                descripcion == null || descripcion.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Faltan datos obligatorios"));
            }

            // Usamos el username del JWT — el campo "usernameCreador" del body se ignora.
            String username = authentication.getName();

            Aviso avisoCreado = avisoService.crearAviso(titulo, descripcion, fecha, username);
            return ResponseEntity.ok(avisoCreado);

        } catch (IllegalStateException e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "Error al crear aviso: " + e.getMessage()));
        }
    }
}