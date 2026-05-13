package com.proyect.backend.repository;

import com.proyect.backend.model.Aviso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AvisoRepository extends JpaRepository<Aviso, Long> {

    // INSEGURO — devuelve avisos de TODAS las comunidades. Solo se mantiene para referencia.
    // NO usar en producción.
    List<Aviso> findAllByFechaAvisoOrderByIdDesc(LocalDate fecha);

    // SEGURO — filtra por la comunidad del creador, garantizando aislamiento entre comunidades.
    // La relación es: Aviso → creador (Usuario) → comunidad (Comunidad)
    @Query("SELECT a FROM Aviso a " +
           "WHERE a.fechaAviso = :fecha " +
           "AND a.creador.comunidad.id = :comunidadId " +
           "ORDER BY a.id DESC")
    List<Aviso> findByComunidadIdAndFechaAviso(
            @Param("comunidadId") Long comunidadId,
            @Param("fecha") LocalDate fecha);
}