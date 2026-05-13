package com.proyect.backend.repository;

import com.proyect.backend.model.Voto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VotoRepository extends JpaRepository<Voto, Long> {

    // ¿Ya votó este usuario en esta votación? (para bloquear doble voto)
    boolean existsByVotacionIdAndUsuarioUsername(Long votacionId, String username);

    // Obtener el voto de un usuario en una votación concreta (para saber qué opción eligió)
    Optional<Voto> findByVotacionIdAndUsuarioUsername(Long votacionId, String username);

    // Contar votos de una opción concreta (para los resultados)
    long countByOpcionId(Long opcionId);
}
