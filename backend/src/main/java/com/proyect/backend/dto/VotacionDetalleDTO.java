package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VotacionDetalleDTO {
    private Long id;
    private String titulo;
    private String descripcion;
    private String estado;
    private String creadorUsername;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaLimite;

    private boolean yaVotado;       // ¿ha votado el usuario que consulta?
    private Long opcionVotadaId;    // id de la opción elegida (null si no ha votado)

    private int totalVotos;
    private List<OpcionDetalleDTO> opciones;
}
