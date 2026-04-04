package com.proyect.backend.repository;

import com.proyect.backend.model.Carpeta;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CarpetaRepository extends JpaRepository<Carpeta, Long> {
    List<Carpeta> findByComunidadId(Long comunidadId);
}