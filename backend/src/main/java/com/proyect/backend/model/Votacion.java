package com.proyect.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "votaciones")
public class Votacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Builder.Default
    @Column(nullable = false)
    private String estado = "ABIERTA"; // "ABIERTA" | "CERRADA"

    @Column(nullable = false)
    private LocalDateTime fechaCreacion;

    // Opcional: fecha en la que la votación se cierra automáticamente.
    // null = abierta indefinidamente hasta que el presidente la cierre.
    @Column
    private LocalDateTime fechaLimite;

    @ManyToOne
    @JoinColumn(name = "comunidad_id", nullable = false)
    @JsonIgnore
    private Comunidad comunidad;

    @ManyToOne
    @JoinColumn(name = "creador_username", referencedColumnName = "username", nullable = false)
    private Usuario creador;

    // CascadeType.ALL + orphanRemoval:
    // - Si se borra la Votacion, sus OpcionVotacion se borran (y en cascada, sus Votos).
    // - Si se elimina una OpcionVotacion de esta lista, se borra de la BD.
    @Builder.Default
    @OneToMany(mappedBy = "votacion", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<OpcionVotacion> opciones = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        this.fechaCreacion = LocalDateTime.now();
    }
}
