package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String token;
    // AÑADID ESTOS CAMPOS PARA QUE FLUTTER LOS RECIBA:
    private String username;
    private String nombre;
    private String apellidos;
    private String email;
    private String rol;
    private Long id; // Si lo necesitas
}