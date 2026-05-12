package com.proyect.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PermisosVecinoRequest {
    private boolean permisoCrearAvisos;
    private boolean permisoGestionarDocumentos;
    private boolean permisoGestionarReservas;
}