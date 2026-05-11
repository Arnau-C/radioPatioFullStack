package com.proyect.backend.controller;

import com.proyect.backend.model.Reserva;
import com.proyect.backend.service.ReservaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    @Autowired
    private ReservaService reservaService;

    // Endpoint para crear una nueva reserva
    @PostMapping
    public ResponseEntity<?> crearReserva(@RequestBody Reserva reserva) {
        try {
            // Intentamos crear la reserva usando la lógica de nuestro servicio
            Reserva nuevaReserva = reservaService.crearReserva(reserva);
            
            // Si todo va bien, devolvemos un 201 (Created) y la reserva confirmada
            return ResponseEntity.status(HttpStatus.CREATED).body(nuevaReserva);
            
        } catch (IllegalArgumentException e) {
            // Error 400 (Bad Request): Si las fechas están mal (ej. fin antes de inicio)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
                    
        } catch (IllegalStateException e) {
            // Error 409 (Conflict): ¡El error clave! Alguien ya ha reservado a esa hora
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", e.getMessage()));
                    
        } catch (Exception e) {
            // Error 500: Por si peta la base de datos o pasa algo raro
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error interno al procesar la reserva."));
        }
    }

    @GetMapping("/recurso/{recursoId}")
    public ResponseEntity<List<Reserva>> obtenerReservasPorRecurso(@PathVariable Long recursoId) {
        return ResponseEntity.ok(reservaService.obtenerReservasPorRecurso(recursoId));
    }

    @GetMapping("/comunidad/{comunidadId}")
    public ResponseEntity<List<Reserva>> obtenerReservasPorComunidad(@PathVariable Long comunidadId) {
        return ResponseEntity.ok(reservaService.obtenerReservasPorComunidad(comunidadId));
    }
}