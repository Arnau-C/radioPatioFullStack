package com.proyect.backend.repository;

import com.proyect.backend.model.Foro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ForoRepository extends JpaRepository<Foro, Long> {
    // Aquí puedes añadir métodos de búsqueda personalizados en el futuro si los necesitas
}