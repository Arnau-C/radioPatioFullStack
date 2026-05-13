package com.proyect.backend.service;

import com.proyect.backend.model.Recurso;
import com.proyect.backend.model.Reserva;
import com.proyect.backend.repository.RecursoRepository;
import com.proyect.backend.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class ReservaService {

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private RecursoRepository recursoRepository;

    @Transactional
    public Reserva crearReserva(Reserva nuevaReserva) {

        // 1. Validaciones básicas de tiempo
        if (nuevaReserva.getFechaInicio().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("No puedes reservar en el pasado.");
        }
        if (nuevaReserva.getFechaFin().isBefore(nuevaReserva.getFechaInicio()) ||
            nuevaReserva.getFechaFin().isEqual(nuevaReserva.getFechaInicio())) {
            throw new IllegalArgumentException("La fecha de fin debe ser posterior a la de inicio.");
        }

        // 2. Comprobar solapamientos
        boolean ocupado = reservaRepository.existeSolapamiento(
                nuevaReserva.getRecurso().getId(),
                nuevaReserva.getFechaInicio(),
                nuevaReserva.getFechaFin()
        );
        if (ocupado) {
            throw new IllegalStateException("El recurso ya está reservado en ese horario.");
        }

        // 3. Validar cuota diaria (solo aplica a recursos POR_HORAS)
        Recurso recurso = recursoRepository.findById(nuevaReserva.getRecurso().getId())
                .orElseThrow(() -> new IllegalArgumentException("Espacio no encontrado."));

        if ("POR_HORAS".equals(recurso.getTipoReserva())) {
            LocalDateTime inicioDia = nuevaReserva.getFechaInicio().toLocalDate().atStartOfDay();
            LocalDateTime finDia    = inicioDia.plusDays(1);

            List<Reserva> reservasDelDia = reservaRepository.findReservasDeUsuarioEnDia(
                    recurso.getId(),
                    nuevaReserva.getUsuario().getUsername(),
                    inicioDia,
                    finDia
            );

            long horasYaReservadas = reservasDelDia.stream()
                    .mapToLong(r -> ChronoUnit.HOURS.between(r.getFechaInicio(), r.getFechaFin()))
                    .sum();

            long horasNuevas = ChronoUnit.HOURS.between(
                    nuevaReserva.getFechaInicio(), nuevaReserva.getFechaFin());

            if (horasYaReservadas + horasNuevas > recurso.getMaxHorasReserva()) {
                throw new IllegalStateException(
                    "Cuota diaria superada: el límite es " + recurso.getMaxHorasReserva() +
                    "h/día en este espacio y ya tienes " + horasYaReservadas + "h reservadas hoy."
                );
            }
        }

        // 4. Guardar
        return reservaRepository.save(nuevaReserva);
    }

    public java.util.List<Reserva> obtenerReservasPorRecurso(Long recursoId) {
        return reservaRepository.findByRecursoId(recursoId);
    }

    public java.util.List<Reserva> obtenerReservasPorComunidad(Long comunidadId) {
        return reservaRepository.findByComunidadId(comunidadId);
    }
}