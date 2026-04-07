package com.proyect.backend.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.proyect.backend.model.Comunidad;
import com.proyect.backend.repository.ComunidadRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class InvitationService {
    private final ComunidadRepository comunidadRepository;
    private static final String CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int CODE_LENGTH = 6;

    public String generarCodigoComunidad(Long id){
        Optional<Comunidad> comunidadOpt = comunidadRepository.findById(id);

        if (!comunidadOpt.isPresent()) {
            throw new IllegalArgumentException("Comunidad no encontrada con ID: " + id);
        }

        Comunidad comunidad = comunidadOpt.get();

        String nuevoCodigo = generarRandomString();
        
        // Guardamos en la comunidad
        comunidad.setCodigoInvitacion(nuevoCodigo);
        comunidad.setFechaExpiracionCodigo(LocalDateTime.now().plusDays(30)); // Validez de 30 días
        
        comunidadRepository.save(comunidad);
        
        return nuevoCodigo;
    }
    public Comunidad validarCodigo(String codigo) {
        // Buscamos la comunidad que tenga este código
        Optional<Comunidad> comunidadOpt = comunidadRepository.findByCodigoInvitacion(codigo);

        if (comunidadOpt.isEmpty()) {
            throw new IllegalArgumentException("El código de invitación no existe.");
        }

        Comunidad comunidad = comunidadOpt.get();

        // Verificamos si ha caducado
        if (comunidad.getFechaExpiracionCodigo().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Este código de invitación ha caducado. Pide uno nuevo al presidente.");
        }

        return comunidad;
    }
    private String generarRandomString() {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(CODE_LENGTH);
        for (int i = 0; i < CODE_LENGTH; i++) {
            sb.append(CHARACTERS.charAt(random.nextInt(CHARACTERS.length())));
        }
        return sb.toString();
    }
    
}
