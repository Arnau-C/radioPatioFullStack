package com.proyect.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
    name = "votos",
    uniqueConstraints = {
        // Garantía a nivel de BD: un usuario solo puede votar UNA VEZ por votación,
        // independientemente de la opción que elija.
        @UniqueConstraint(
            name = "uc_un_voto_por_votacion",
            columnNames = {"votacion_id", "usuario_username"}
        )
    }
)
public class Voto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // La opción concreta que eligió el usuario.
    @ManyToOne
    @JoinColumn(name = "opcion_id", nullable = false)
    @JsonIgnore
    private OpcionVotacion opcion;

    // Columna redundante necesaria para el UniqueConstraint a nivel de votación.
    // Sin esta FK, la constraint única solo podría ser (opcion_id, usuario_username),
    // lo que permitiría votar una opción distinta por cada opción de la misma votación.
    @ManyToOne
    @JoinColumn(name = "votacion_id", nullable = false)
    @JsonIgnore
    private Votacion votacion;

    @ManyToOne
    @JoinColumn(name = "usuario_username", referencedColumnName = "username", nullable = false)
    @JsonIgnore
    private Usuario usuario;

    @Column(nullable = false)
    private LocalDateTime fechaVoto;

    @PrePersist
    protected void onCreate() {
        this.fechaVoto = LocalDateTime.now();
    }
}
