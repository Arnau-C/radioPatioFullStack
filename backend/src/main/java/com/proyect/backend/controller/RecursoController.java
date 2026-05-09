package com.proyect.backend.controller;

import com.proyect.backend.model.Recurso;
import com.proyect.backend.service.RecursoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recursos")
@CrossOrigin(origins = "*")
public class RecursoController {

    @Autowired
    private RecursoService recursoService;

    @PostMapping("/{comunidadId}")
    public ResponseEntity<?> crearRecurso(@PathVariable Long comunidadId, @RequestBody Recurso recurso, Authentication authentication) {
        try {
            String usernamePresidente = authentication.getName();
            Recurso nuevoRecurso = recursoService.crearRecurso(recurso, comunidadId, usernamePresidente);
            return ResponseEntity.status(HttpStatus.CREATED).body(nuevoRecurso);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "Error interno"));
        }
    }

    @GetMapping("/comunidad/{comunidadId}")
    public ResponseEntity<List<Recurso>> obtenerRecursos(@PathVariable Long comunidadId) {
        return ResponseEntity.ok(recursoService.obtenerRecursosComunidad(comunidadId));
    }

    @DeleteMapping("/{recursoId}")
    public ResponseEntity<?> eliminarRecurso(@PathVariable Long recursoId, Authentication authentication) {
        try {
            String usernamePresidente = authentication.getName();
            recursoService.eliminarRecurso(recursoId, usernamePresidente);
            return ResponseEntity.ok(Map.of("mensaje", "Recurso eliminado correctamente"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        }
    }
}
