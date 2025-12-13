package com.proyect.backend.repository;

import com.proyect.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    
    boolean existsByEmail(String email);
}