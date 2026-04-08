package com.proyect.backend.repository;

import com.proyect.backend.model.Foro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ForoRepository extends JpaRepository<Foro, Long> {
Optional<Foro> findByComunidadId(Long comunidadId);
}