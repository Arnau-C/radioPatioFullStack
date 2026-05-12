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

// Quitamos el @PreAuthorize("hasAuthority('PRESIDENTE')")
// POST /api/avisos/crear -> Crea un aviso (Presidente o Vecino con permisos)
    @PostMapping("/crear")
    public ResponseEntity<?> crearAviso(@RequestBody Map<String, Object> payload) {
        try {
            String titulo = payload.get("titulo").toString();
            String descripcion = payload.get("descripcion").toString();
            String username = payload.get("username").toString();
            
            // 👇 LA SOLUCIÓN: Generamos la fecha aquí para que coincida con el servicio
            LocalDate fechaHoy = LocalDate.now();

            // Llamamos al servicio con los tipos correctos: String, String, LocalDate, String
            Aviso nuevo = avisoService.crearAviso(titulo, descripcion, fechaHoy, username);
            
            return ResponseEntity.ok(nuevo);
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }
}