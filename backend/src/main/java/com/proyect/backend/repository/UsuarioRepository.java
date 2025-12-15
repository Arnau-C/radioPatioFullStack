package com.proyect.backend.repository;

import com.proyect.backend.model.Usuario;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

//Este archivo es el repositorio de usuarios. Es el único que conecta con la base de datos.

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    // Enseñamos a la base de datos a buscar por el campo 'username'
    Optional<Usuario> findByUsername(String username);

    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}