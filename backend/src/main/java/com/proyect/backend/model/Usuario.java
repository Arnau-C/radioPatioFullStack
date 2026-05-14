package com.proyect.backend.model;


import java.util.Collection;
import java.util.List;

//import org.apache.catalina.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

//import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data; // <--- IMPORTANTE
import lombok.NoArgsConstructor;
import lombok.ToString;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
//import jakarta.persistence.GeneratedValue;
//import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;


@Data 
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
// Implementamos UserDetails para integrar con Spring Security
public class Usuario implements UserDetails{
    
    //Primary Key & varchar(50)
    @Id
    @Column(length = 25)
    private String username;

    @Column(nullable = false, length = 100)
    private String password;

    private String nombre; // Si no ponemos @Column, asume el mismo nombre y que puede ser null.
    private String apellidos;

    @Column(nullable = false, unique = true) // El email debe ser único también.
    private String email;

    private String rol; // 'ADMIN', 'USER', etc.

    @Builder.Default
    private int intentosFallidos = 0;

    @Builder.Default
    private boolean cuentaBloqueada = false;

    @Builder.Default
    private boolean permisoCrearAvisos = false;

    @Builder.Default
    private boolean permisoGestionarDocumentos = false;

    @Builder.Default
    private boolean permisoGestionarRecursos = false;

    @Builder.Default
    private boolean permisoCrearVotaciones = false;

    @Builder.Default
    private boolean permisoGestionarIncidencias = false;

    @OneToMany(mappedBy = "usuario")
    @ToString.Exclude  // Evita que toString() entre en bucle infinito
    @JsonIgnore // Evita ciclos infinitos en la serialización JSON
    private List<LoginLog> logs;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        String rolSeguro = (rol == null) ? "USER" : rol;
        return List.of(new SimpleGrantedAuthority(rolSeguro));
    }

    @ManyToOne
    @JoinColumn(name = "comunidad_id")
    @JsonIgnore
    private Comunidad comunidad;

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // La cuenta nunca caduca (a menos que tú quieras)
    }

    @Override
    public boolean isAccountNonLocked() {
        return !cuentaBloqueada; // Si NO está bloqueada, devuelve true (puede entrar)
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // La contraseña no caduca
    }

    @Override
    public boolean isEnabled() {
        return true; // El usuario está habilitado
    }
}
