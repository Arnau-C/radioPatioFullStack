package com.proyect.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.proyect.backend.service.AuthService;
import com.proyect.backend.dto.LoginRequest; 
import com.proyect.backend.dto.RegisterRequest; 
import com.proyect.backend.dto.AuthResponse;

import lombok.RequiredArgsConstructor;


//Controlador REST para la autenticación (registro y login). Conectan las peticiones HTTP con el servicio de autenticación.

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // Permitir solicitudes desde cualquier origen
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/registro")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
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
}