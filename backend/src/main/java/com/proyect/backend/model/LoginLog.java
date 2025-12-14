package com.proyect.backend.model;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
//import jakarta.persistence.*;
import lombok.Data; // <--- IMPORTANTE

@Data
@Entity
@Table(name = "login_logs")
public class LoginLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    // 1. Aquí SÍ usamos autoincrement porque cada log es una línea nueva y única.
    private Long id;

    // 2. Aquí está la relación con la tabla de usuarios.
    // ManyToOne significa: "Muchos logs pueden pertenecer a Un usuario".
    @ManyToOne 
    @JoinColumn(name = "username_usuario", referencedColumnName = "username")
    private Usuario usuario; 
    // Fíjate que en Java guardamos el objeto 'User' completo, 
    // pero en SQL Spring creará una columna 'username_usuario' que guarda el texto.

    private LocalDateTime fechaHora; // Guarda fecha y hora exacta.

    private boolean exito; // true = entró, false = falló.

    private String motivoFallo; // "Contraseña mal", "Bloqueado", etc.
    
    private String sistemaOrigen; // "Web", "App", etc.
}
