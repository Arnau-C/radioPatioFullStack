package com.proyect.backend.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "comunidades")
public class Comunidad {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false)
    private String direccion;

    // Relación con Usuario (presidente), one-to-one porque cada comunidad tiene un presidente único y cada usuario puede ser presidente de una sola comunidad.
    @OneToOne
    @JoinColumn(name = "presidente_username", referencedColumnName = "username")
    private Usuario presidente;

    @Column(nullable = false, unique = true, length = 10)
    private String codigoInvitacion;

    @Column(nullable = false)
    private LocalDateTime fechaCreacion;

    //Metodo que se ejecuta antes de persistir la entidad para establecer la fecha de creación
    protected void onCreate() {
        this.fechaCreacion = LocalDateTime.now();
    }   
}
