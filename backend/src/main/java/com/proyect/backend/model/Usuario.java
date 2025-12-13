package com.proyect.backend.model;


import jakarta.persistence.*;
import lombok.Data; // <--- IMPORTANTE
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Data 
@Entity
@Table(name = "users")
public class Usuario {
    
    //Primary Key & varchar(50)
    @Id
    @Column(length = 25)
    private String username;

    @Column(nullable = false)
    private String password;

    private String nombre; // Si no ponemos @Column, asume el mismo nombre y que puede ser null.
    private String apellidos;

    @Column(nullable = false, unique = true) // El email debe ser único también.
    private String email;

    private String rol; // 'ADMIN', 'USER', etc.

    private int intentosFallidos = 0; // Para contar los errores de login.

    private boolean cuentaBloqueada = false; // Para saber si está bloqueado.
}
