package com.proyect.backend.repository;

import com.proyect.backend.model.Votacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VotacionRepository extends JpaRepository<Votacion, Long> {

    // Todas las votaciones de una comunidad, más recientes primero
    List<Votacion> findByComunidadIdOrderByFechaCreacionDesc(Long comunidadId);
}
