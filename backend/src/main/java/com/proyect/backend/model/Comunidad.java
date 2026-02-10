package com.proyect.backend.model;

import java.time.LocalDateTime;
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
@Table(name = "comunidades")
public class Comunidad {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false)
    private String direccion;

    @OneToOne
    @JoinColumn(name = "presidente_username", referencedColumnName = "username")
    private Usuario presidente;


    @Column(nullable = false)
    private LocalDateTime fechaCreacion;
    
    @Column(unique = true)
    private String codigoInvitacion;
    private LocalDateTime fechaExpiracionCodigo;

    protected void onCreate() {
        this.fechaCreacion = LocalDateTime.now();
    }
}