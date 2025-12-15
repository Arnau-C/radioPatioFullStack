package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

//Son los datos que recibiremos al registrar un nuevo usuario desde el frontend.

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    private String username;
    private String password;
    private String nombre;
    private String apellidos;
    private String email;
}