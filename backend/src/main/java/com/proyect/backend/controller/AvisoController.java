package com.proyect.backend.controller;

import com.proyect.backend.model.Aviso;
import com.proyect.backend.service.AvisoService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/avisos")
@RequiredArgsConstructor
public class AvisoController {

    private final AvisoService avisoService;

    // GET /api/avisos?fecha=2024-03-24 -> Obtiene avisos de esa fecha (Para todos los usuarios)
    @GetMapping
    public ResponseEntity<List<com.proyect.backend.dto.AvisoDTO>> obtenerAvisos(
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate fecha) {
        
        List<com.proyect.backend.dto.AvisoDTO> lista = avisoService.obtenerAvisosPorFecha(fecha).stream()
                .map(aviso -> com.proyect.backend.dto.AvisoDTO.builder()
                        .id(aviso.getId())
                        .titulo(aviso.getTitulo())
                        .descripcion(aviso.getDescripcion())
                        .fechaAviso(aviso.getFechaAviso())
                        .creadorUsername(aviso.getCreador().getUsername())
                        .build())
                .toList();
                
        return ResponseEntity.ok(lista);
    }

    // POST /api/avisos -> Crea un aviso (SOLO PRESIDENTE)
    @PostMapping
    @PreAuthorize("hasAuthority('PRESIDENTE')")// Seguridad: Solo el rol PRESIDENTE puede entrar aquí
    public ResponseEntity<?> crearAviso(@RequestBody Map<String, Object> payload) {
        try {
            String titulo = (String) payload.get("titulo");
            String descripcion = (String) payload.get("descripcion");
            String fechaStr = (String) payload.get("fecha"); // Viene como YYYY-MM-DD
            LocalDate fecha = LocalDate.parse(fechaStr);
            String username = (String) payload.get("usernameCreador");

            if (titulo == null || titulo.isEmpty() || descripcion == null || descripcion.isEmpty() || fecha == null) {
                 return ResponseEntity.badRequest().body(Map.of("error", "Faltan datos obligatorios"));
            }

            Aviso avisoCreado = avisoService.crearAviso(titulo, descripcion, fecha, username);
            return ResponseEntity.ok(avisoCreado);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Error al crear aviso: " + e.getMessage()));
        }
    }
}