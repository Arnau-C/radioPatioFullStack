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
@Table(name = "documentos")
public class Documento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo; // Ej: "Factura Luz Enero"

    @Column(nullable = false)
    private String rutaArchivo; // Ruta local o URL del PDF

    @Enumerated(EnumType.STRING)
    @Builder.Default
    @Column(nullable = false)
    private TipoDocumento tipoDocumento = TipoDocumento.OTROS; 

    @ManyToOne
    @JoinColumn(name = "subido_por_username", referencedColumnName = "username", nullable = false)
    private Usuario subidoPor;

    @ManyToOne
    @JoinColumn(name = "comunidad_id", nullable = false)
    private Comunidad comunidad;

    @Column(nullable = false)
    private LocalDateTime fechaSubida;

    @PrePersist
    protected void onCreate() {
        this.fechaSubida = LocalDateTime.now();
    }
}