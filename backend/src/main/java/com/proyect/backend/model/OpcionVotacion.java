package com.proyect.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "opciones_votacion")
public class OpcionVotacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String texto;

    // Back-reference a la votación padre. @JsonIgnore rompe el ciclo
    // Votacion → opciones → OpcionVotacion → votacion → ...
    @ManyToOne
    @JoinColumn(name = "votacion_id", nullable = false)
    @JsonIgnore
    private Votacion votacion;

    // La lista de votos se gestiona internamente.
    // Nunca se serializa: el conteo se hace mediante query, no cargando toda la lista.
    @Builder.Default
    @OneToMany(mappedBy = "opcion", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Voto> votos = new ArrayList<>();
}
