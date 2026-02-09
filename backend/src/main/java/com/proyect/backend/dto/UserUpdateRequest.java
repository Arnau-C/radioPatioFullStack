package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO para actualizar los datos del usuario (sin contraseña), usado en el AdminPanel
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserUpdateRequest {
    private String nombre;
    private String apellidos;
    private String email;
    private String rol; 
    private Boolean cuentaBloqueada;
}