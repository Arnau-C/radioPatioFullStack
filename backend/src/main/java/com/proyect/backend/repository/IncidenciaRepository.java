package com.proyect.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.proyect.backend.model.Incidencia;

public interface IncidenciaRepository extends JpaRepository<Incidencia, Long> {

    List<Incidencia> findByComunidadIdAndEstadoNot(Long comunidadId, String estado);
}
