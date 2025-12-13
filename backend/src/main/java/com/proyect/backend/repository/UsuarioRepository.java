package com.proyect.backend.repository;

import com.proyect.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// IMPORTANTE: <Usuario, String> porque el @Id (username) es un String
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    // Ya no necesitas 'existsByUsername' porque 'existsById' hará lo mismo.
    
    // Solo necesitamos buscar por email:
    boolean existsByEmail(String email);
}