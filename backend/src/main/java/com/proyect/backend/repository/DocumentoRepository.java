package com.proyect.backend.repository;

import com.proyect.backend.model.Documento;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DocumentoRepository extends JpaRepository<Documento, Long> {
    List<Documento> findByCarpetaId(Long carpetaId);
    boolean existsByCarpetaId(Long carpetaId); // Vital para evitar borrar carpetas llenas
}