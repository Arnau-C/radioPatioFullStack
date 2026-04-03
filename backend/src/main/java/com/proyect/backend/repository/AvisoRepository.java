package com.proyect.backend.repository;

import com.proyect.backend.model.Aviso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AvisoRepository extends JpaRepository<Aviso, Long> {
    // Busca todos los avisos para una fecha específica, ordenados por ID descendente (los más nuevos primero)
    List<Aviso> findAllByFechaAvisoOrderByIdDesc(LocalDate fecha);
}