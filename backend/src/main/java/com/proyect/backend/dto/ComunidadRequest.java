package com.proyect.backend.dto;

import lombok.Data;

@Data
public class ComunidadRequest {
    private String nombre;
    private String direccion;
    private String presidenteUsername; // Necesitamos saber quién la crea
}