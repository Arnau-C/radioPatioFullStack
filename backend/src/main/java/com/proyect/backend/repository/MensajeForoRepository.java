package com.proyect.backend.repository;

import com.proyect.backend.model.MensajeForo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MensajeForoRepository extends JpaRepository<MensajeForo, Long> {
    // Busca mensajes de un foro específico, del más antiguo al más nuevo para el chat
    List<MensajeForo> findByForoIdOrderByFechaEnvioAsc(Long foroId);
}