package com.proyect.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.proyect.backend.service.AuthService;

import jakarta.validation.Valid;

import com.proyect.backend.dto.LoginRequest; 
import com.proyect.backend.dto.RegisterRequest;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.dto.AuthResponse;

import lombok.RequiredArgsConstructor;


//Controlador REST para la autenticación (registro y login). Conectan las peticiones HTTP con el servicio de autenticación.

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PutMapping("/registro")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        // El servicio se encarga de:
        // 1. Crear el usuario
        // 2. Encriptar contraseña
        // 3. Guardar en BD
        // 4. Generar el Token
        return ResponseEntity.ok(authService.register(request));
    }
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
   @org.springframework.web.bind.annotation.DeleteMapping("/borrar/{username}")
    public ResponseEntity<?> eliminarUsuario(@org.springframework.web.bind.annotation.PathVariable String username) {
        try {
            // Enviamos el nombre "goat"
            authService.eliminarUsuario(username);
            
            return ResponseEntity.ok("Usuario " + username + " eliminado correctamente");
        } catch (Exception e) {
            return ResponseEntity.status(404).body("Error: " + e.getMessage());
        }
    }
    @org.springframework.web.bind.annotation.PutMapping("/modificar/{username}")
    public ResponseEntity<?> modificarUsuario(
            @org.springframework.web.bind.annotation.PathVariable String username,
            @org.springframework.web.bind.annotation.RequestBody com.proyect.backend.dto.RegisterRequest request) { // Usamos RegisterRequest para no crear líos con DTOs nuevos
        
        try {
            // Llamamos a la función de actualizar que YA EXISTE en el servicio
            authService.actualizarUsuario(username, request);
            
            return ResponseEntity.ok("Usuario modificado con éxito");
        } catch (Exception e) {
            return ResponseEntity.status(404).body("Error al modificar: " + e.getMessage());
        }
    }

    @PutMapping("/update/{username}")
public ResponseEntity<?> updateProfile(@PathVariable String username, @RequestBody RegisterRequest request) {
    try {
        Usuario actualizado = authService.actualizarUsuario(username, request);
        return ResponseEntity.ok(actualizado);
    } catch (Exception e) {
        return ResponseEntity.badRequest().body("Error al actualizar: " + e.getMessage());
    }
}

}