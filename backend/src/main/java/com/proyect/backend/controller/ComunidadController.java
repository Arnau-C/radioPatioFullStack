package com.proyect.backend.controller;

import com.proyect.backend.dto.ComunidadRequest;
import com.proyect.backend.model.Comunidad;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ComunidadRepository;
import com.proyect.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/comunidades")
@CrossOrigin(origins = "*")
public class ComunidadController {

    @Autowired
    private ComunidadRepository comunidadRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @PostMapping("/crear")
    public ResponseEntity<?> crearComunidad(@RequestBody ComunidadRequest request) {
        // 1. Buscamos al usuario (el creador será el presidente)
        Usuario presidente = usuarioRepository.findByUsername(request.getPresidenteUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // 2. Creamos la Comunidad (SIN CÓDIGO)
        Comunidad nuevaComunidad = Comunidad.builder()
                .nombre(request.getNombre())
                .direccion(request.getDireccion()) // Asegúrate de que en el DTO se llame getDireccion
                .presidente(presidente)
                .fechaCreacion(LocalDateTime.now())
                .build();

        // 3. Guardamos
        comunidadRepository.save(nuevaComunidad);

        return ResponseEntity.ok("Comunidad creada con éxito");
    }
}