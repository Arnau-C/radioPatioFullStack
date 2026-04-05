package com.proyect.backend.controller;

import com.proyect.backend.dto.MensajeDTO;
import com.proyect.backend.model.MensajeForo;
import com.proyect.backend.model.Foro;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.MensajeForoRepository;
import com.proyect.backend.repository.ForoRepository;
import com.proyect.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/foros")
@RequiredArgsConstructor
public class ForoController {

    private final MensajeForoRepository mensajeRepository;
    private final ForoRepository foroRepository;
    private final UsuarioRepository usuarioRepository;

    // Obtener todos los mensajes de un foro
    @GetMapping("/{foroId}/mensajes")
    public ResponseEntity<List<MensajeDTO>> obtenerMensajes(@PathVariable Long foroId) {
        List<MensajeDTO> mensajes = mensajeRepository.findByForoIdOrderByFechaEnvioAsc(foroId).stream()
                .map(m -> MensajeDTO.builder()
                        .id(m.getId())
                        .contenido(m.getContenido())
                        .autorNombre(m.getAutor().getNombre() + " " + m.getAutor().getApellidos())
                        .autorUsername(m.getAutor().getUsername())
                        .fechaEnvio(m.getFechaEnvio())
                        .build())
                .toList();
        return ResponseEntity.ok(mensajes);
    }

    // Publicar un nuevo mensaje
    @PostMapping("/{foroId}/mensajes")
    public ResponseEntity<?> publicarMensaje(@PathVariable Long foroId, @RequestBody Map<String, String> payload) {
        String contenido = payload.get("contenido");
        String username = payload.get("username");

        Foro foro = foroRepository.findById(foroId).orElseThrow();
        Usuario autor = usuarioRepository.findByUsername(username).orElseThrow();

        MensajeForo nuevoMensaje = MensajeForo.builder()
                .contenido(contenido)
                .foro(foro)
                .autor(autor)
                .build();

        mensajeRepository.save(nuevoMensaje);
        return ResponseEntity.ok().build();
    }
}