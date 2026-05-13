package com.proyect.backend.exceptions;

import java.util.HashMap;
import java.util.Map;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalException {

    // 400 — datos incorrectos o entidad no encontrada
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleArgumentException(IllegalArgumentException e) {
        return error(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

    // 403 — acción no permitida (rol incorrecto, votación cerrada, ya votó, etc.)
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, String>> handleStateException(IllegalStateException e) {
        return error(e.getMessage(), HttpStatus.FORBIDDEN);
    }

    // 409 — violación de clave única en BD (doble voto por condición de carrera)
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> handleIntegrityException(DataIntegrityViolationException e) {
        return error("Ya has votado en esta votación.", HttpStatus.CONFLICT);
    }

    private ResponseEntity<Map<String, String>> error(String message, HttpStatus status) {
        Map<String, String> body = new HashMap<>();
        body.put("error", message);
        return new ResponseEntity<>(body, status);
    }
}
