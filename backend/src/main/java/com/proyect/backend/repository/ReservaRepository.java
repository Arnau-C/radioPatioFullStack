package com.proyect.backend.repository;

import com.proyect.backend.model.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReservaRepository extends JpaRepository<Reserva, Long> {

    // Comprueba si hay reservas activas que se solapen con las fechas solicitadas
    @Query("SELECT COUNT(r) > 0 FROM Reserva r WHERE r.recurso.id = :recursoId " +
           "AND r.estado = 'ACTIVA' " +
           "AND (r.fechaInicio < :fechaFin AND r.fechaFin > :fechaInicio)")
    boolean existeSolapamiento(@Param("recursoId") Long recursoId, 
                               @Param("fechaInicio") LocalDateTime fechaInicio, 
                               @Param("fechaFin") LocalDateTime fechaFin);

    // Reservas activas de un usuario en un recurso dentro de un día concreto
    // Se compara por rango de LocalDateTime (inicio del día — inicio del día siguiente)
    @Query("SELECT r FROM Reserva r WHERE r.recurso.id = :recursoId " +
           "AND r.usuario.username = :username " +
           "AND r.estado = 'ACTIVA' " +
           "AND r.fechaInicio >= :inicioDia AND r.fechaInicio < :finDia")
    List<Reserva> findReservasDeUsuarioEnDia(
            @Param("recursoId") Long recursoId,
            @Param("username") String username,
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia);

    // Obtener todas las reservas de un recurso específico
    List<Reserva> findByRecursoId(Long recursoId);

    // Obtener todas las reservas asociadas a los recursos de una comunidad específica, ordenadas por fecha
    @Query("SELECT r FROM Reserva r WHERE r.recurso.comunidad.id = :comunidadId ORDER BY r.fechaInicio ASC")
    List<Reserva> findByComunidadId(@Param("comunidadId") Long comunidadId);
}