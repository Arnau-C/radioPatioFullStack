package com.proyect.backend.exceptions;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

// Clase para manejar excepciones globalmente en la aplicación
@ControllerAdvice
public class GlobalException {

    // Maneja IllegalArgumentException lanzadas en cualquier parte del controlador
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleArgumentException(IllegalArgumentException e) {
        Map<String, String> response = new HashMap<>();
        // Agregamos el mensaje de la excepción al mapa de respuesta
        response.put("message", e.getMessage());
        
        // Devolvemos una respuesta con el mapa y el estado BAD_REQUEST (400)
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
}
