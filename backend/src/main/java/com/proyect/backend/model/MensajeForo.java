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
@Table(name = "mensajes_foro")
public class MensajeForo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String contenido;

    @ManyToOne
    @JoinColumn(name = "foro_id", nullable = false)
    private Foro foro;
    
    @Column(nullable = false)
    @Builder.Default 
    private boolean destacado = false;

    @ManyToOne
    @JoinColumn(name = "autor_username", referencedColumnName = "username", nullable = false)
    private Usuario autor;

    @ManyToOne
    @JoinColumn(name = "respuesta_a_id")
    private MensajeForo respuestaA;

    @Column(nullable = false)
    private LocalDateTime fechaEnvio;

    @PrePersist
    protected void onCreate() {
        this.fechaEnvio = LocalDateTime.now();
    }
}