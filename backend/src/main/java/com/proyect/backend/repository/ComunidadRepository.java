package com.proyect.backend.repository;

import com.proyect.backend.model.Comunidad;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ComunidadRepository extends JpaRepository<Comunidad, Long> {
   Optional<Comunidad> findByCodigoInvitacion(String codigoInvitacion);
}