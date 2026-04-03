package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AvisoDTO {
    private Long id;
    private String titulo;
    private String descripcion;
    private LocalDate fechaAviso;
    private String creadorUsername;
}