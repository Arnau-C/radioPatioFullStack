package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

//DTO para la respuesta de autenticación que incluye el token JWT y detalles del usuario.
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String token;
    private String username;
    private String nombre;
    private String apellidos;
    private String email;
    private String rol;
    private Long id; 
}