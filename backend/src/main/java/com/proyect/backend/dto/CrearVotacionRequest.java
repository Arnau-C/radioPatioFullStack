package com.proyect.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CrearVotacionRequest {
    private String titulo;
    private String descripcion;
    private List<String> opciones;  // textos de las opciones
    private LocalDateTime fechaLimite; // nullable — sin límite si no se envía
}
