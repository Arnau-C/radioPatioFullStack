package com.proyect.backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.proyect.backend.dto.IncidenciaRequest;
import com.proyect.backend.model.Incidencia;
import com.proyect.backend.service.IncidenciaService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/comunidades")
@RequiredArgsConstructor
public class IncidenciaController {
    private final IncidenciaService incidenciaService;

    @PostMapping("/{comunidadId}/incidencias")
    public ResponseEntity<Incidencia> crearIncidencia(
            @PathVariable Long comunidadId,
            @RequestBody IncidenciaRequest request,
            Authentication authentication) { // Spring Security inyecta esto automáticamente
        
        // Extraemos el username del usuario que está logueado (desde el JWT)
        String username = authentication.getName(); 
        
        Incidencia nuevaIncidencia = incidenciaService.crearIncidencia(comunidadId, request, username);
        
        return new ResponseEntity<>(nuevaIncidencia, HttpStatus.CREATED);
    }

    @GetMapping("/{comunidadId}/incidencias")
    public ResponseEntity<List<Incidencia>> obtenerIncidencias(@PathVariable Long comunidadId) {
        // En tu IncidenciaService deberías filtrar para que solo devuelva las no resueltas
        List<Incidencia> incidencias = incidenciaService.obtenerIncidenciasPendientes(comunidadId);
        return ResponseEntity.ok(incidencias);
    }

    // 2. Marcar una incidencia como resuelta
    @PutMapping("/{comunidadId}/incidencias/{incidenciaId}/resolver")
    public ResponseEntity<Void> resolverIncidencia(
            @PathVariable Long comunidadId,
            @PathVariable Long incidenciaId,
            Authentication authentication) {
        
        String username = authentication.getName();
        // Llamamos al servicio para que cambie el estado en la base de datos
        incidenciaService.resolverIncidencia(comunidadId, incidenciaId, username);
        
        return ResponseEntity.ok().build();
    }
}
