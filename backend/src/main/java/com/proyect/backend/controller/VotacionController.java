package com.proyect.backend.controller;

import com.proyect.backend.dto.CrearVotacionRequest;
import com.proyect.backend.dto.EmitirVotoRequest;
import com.proyect.backend.dto.VotacionDetalleDTO;
import com.proyect.backend.service.VotacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/votaciones")
@RequiredArgsConstructor
public class VotacionController {

    private final VotacionService votacionService;

    // --- CREAR VOTACIÓN (solo PRESIDENTE) ---
    // POST /api/votaciones/comunidad/{comunidadId}
    @PostMapping("/comunidad/{comunidadId}")
    public ResponseEntity<VotacionDetalleDTO> crearVotacion(
            @PathVariable Long comunidadId,
            @RequestBody CrearVotacionRequest request,
            Authentication authentication) {

        VotacionDetalleDTO dto = votacionService.crearVotacion(
                comunidadId, request, authentication.getName());
        return ResponseEntity.status(HttpStatus.CREATED).body(dto);
    }

    // --- LISTAR VOTACIONES DE UNA COMUNIDAD ---
    // GET /api/votaciones/comunidad/{comunidadId}
    @GetMapping("/comunidad/{comunidadId}")
    public ResponseEntity<List<VotacionDetalleDTO>> listarVotaciones(
            @PathVariable Long comunidadId,
            Authentication authentication) {

        return ResponseEntity.ok(
                votacionService.listarVotaciones(comunidadId, authentication.getName()));
    }

    // --- OBTENER DETALLE / RESULTADOS (endpoint de polling) ---
    // Flutter llama a este endpoint cada ~4 segundos mientras el usuario está en pantalla.
    // GET /api/votaciones/{votacionId}
    @GetMapping("/{votacionId}")
    public ResponseEntity<VotacionDetalleDTO> obtenerDetalle(
            @PathVariable Long votacionId,
            Authentication authentication) {

        return ResponseEntity.ok(
                votacionService.obtenerDetalle(votacionId, authentication.getName()));
    }

    // --- EMITIR VOTO ---
    // POST /api/votaciones/{votacionId}/votar
    @PostMapping("/{votacionId}/votar")
    public ResponseEntity<VotacionDetalleDTO> emitirVoto(
            @PathVariable Long votacionId,
            @RequestBody EmitirVotoRequest request,
            Authentication authentication) {

        VotacionDetalleDTO dto = votacionService.emitirVoto(
                votacionId, request, authentication.getName());
        return ResponseEntity.status(HttpStatus.CREATED).body(dto);
    }

    // --- CERRAR VOTACIÓN (solo PRESIDENTE) ---
    // PUT /api/votaciones/{votacionId}/cerrar
    @PutMapping("/{votacionId}/cerrar")
    public ResponseEntity<VotacionDetalleDTO> cerrarVotacion(
            @PathVariable Long votacionId,
            Authentication authentication) {

        return ResponseEntity.ok(
                votacionService.cerrarVotacion(votacionId, authentication.getName()));
    }
}
