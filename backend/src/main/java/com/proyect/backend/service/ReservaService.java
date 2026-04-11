package com.proyect.backend.service;

import com.proyect.backend.model.Reserva;
import com.proyect.backend.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class ReservaService {

    @Autowired
    private ReservaRepository reservaRepository;

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

        // 3. Guardar si todo está libre
        return reservaRepository.save(nuevaReserva);
    }

    public java.util.List<Reserva> obtenerReservasPorRecurso(Long recursoId) {
        return reservaRepository.findByRecursoId(recursoId);
    }

    public java.util.List<Reserva> obtenerReservasPorComunidad(Long comunidadId) {
        return reservaRepository.findByComunidadId(comunidadId);
    }
}