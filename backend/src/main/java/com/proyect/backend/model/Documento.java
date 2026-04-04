package com.proyect.backend.model;

import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
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
@Table(name = "documentos")
public class Documento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false)
    private String rutaArchivo; // Ruta donde se guardó físicamente el PDF

    @ManyToOne(fetch = FetchType.EAGER) // Queremos ver siempre en qué carpeta está
    @JoinColumn(name = "carpeta_id", nullable = false)
    @JsonIgnore
    private Carpeta carpeta;

   @ManyToOne(fetch = FetchType.EAGER) 
    @JoinColumn(name = "subido_por_username", referencedColumnName = "username", nullable = false)
    @JsonIgnoreProperties({"password", "email", "intentosFallidos", "cuentaBloqueada", "comunidad", "authorities", "enabled", "role"}) 
    private Usuario subidoPor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comunidad_id", nullable = false)
    @JsonIgnore
    private Comunidad comunidad;

    @Column(nullable = false)
    private LocalDateTime fechaSubida;

    @PrePersist
    protected void onCreate() {
        this.fechaSubida = LocalDateTime.now();
    }
}