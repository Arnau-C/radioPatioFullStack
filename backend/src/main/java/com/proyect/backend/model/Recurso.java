package com.proyect.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "recursos")
public class Recurso { //Recurso es para el tema de que el presidente pueda crear plazas personalizadas para las reservas
 
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre; 

    private String descripcion;

    @Column(nullable = false)
    @Builder.Default
    private String tipoReserva = "POR_HORAS"; // "POR_HORAS" o "POR_DIAS"

    @ManyToOne
    @JoinColumn(name = "comunidad_id", nullable = false)
    private Comunidad comunidad;
}