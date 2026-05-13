package com.proyect.backend.exceptions;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalException {

    // 400 — datos incorrectos o entidad no encontrada
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleArgumentException(IllegalArgumentException e) {
        return error(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

    // 400 — validación de @Valid en DTOs (ej. @Pattern, @NotBlank)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getDefaultMessage())
                .collect(Collectors.joining(". "));
        return error(message.isEmpty() ? "Datos de registro inválidos" : message, HttpStatus.BAD_REQUEST);
    }

    // 403 — acción no permitida (rol incorrecto, votación cerrada, ya votó, etc.)
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, String>> handleStateException(IllegalStateException e) {
        return error(e.getMessage(), HttpStatus.FORBIDDEN);
    }

    // 409 — violación de clave única en BD
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> handleIntegrityException(DataIntegrityViolationException e) {
        // La causa raíz contiene el nombre de la constraint violada
        String cause = e.getMostSpecificCause().getMessage();
        if (cause != null && cause.contains("uc_un_voto_por_votacion")) {
            return error("Ya has votado en esta votación.", HttpStatus.CONFLICT);
        }
        return error("El nombre de usuario o el email ya están en uso.", HttpStatus.CONFLICT);
    }

    private ResponseEntity<Map<String, String>> error(String message, HttpStatus status) {
        Map<String, String> body = new HashMap<>();
        body.put("error", message);
        return new ResponseEntity<>(body, status);
    }
}
