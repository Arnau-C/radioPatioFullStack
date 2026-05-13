package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OpcionDetalleDTO {
    private Long id;
    private String texto;
    private long votos;
    private double porcentaje; // 0.0 – 100.0, calculado en el servicio
}
