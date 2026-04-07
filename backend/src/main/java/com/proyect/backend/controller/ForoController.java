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

    @GetMapping("/{foroId}/mensajes")
    public ResponseEntity<List<MensajeDTO>> obtenerMensajes(@PathVariable Long foroId) {
        List<MensajeDTO> mensajes = mensajeRepository.findByForoIdOrderByFechaEnvioAsc(foroId).stream()
                .map(m -> MensajeDTO.builder()
                        .id(m.getId())
                        .contenido(m.getContenido())
                        .autorNombre(m.getAutor().getNombre() + " " + m.getAutor().getApellidos())
                        .autorUsername(m.getAutor().getUsername())
                        .fechaEnvio(m.getFechaEnvio())
                        .respuestaAId(m.getRespuestaA() != null ? m.getRespuestaA().getId() : null)
                        .respuestaAContenido(m.getRespuestaA() != null ? m.getRespuestaA().getContenido() : null)
                        .respuestaAAutor(m.getRespuestaA() != null ? m.getRespuestaA().getAutor().getNombre() : null)
                        .build())
                .toList();
        return ResponseEntity.ok(mensajes);
    }

    @PostMapping("/{foroId}/mensajes")
    public ResponseEntity<?> enviarMensaje(@PathVariable Long foroId, @RequestBody Map<String, Object> payload) {
        try {
            Foro foro = foroRepository.findById(foroId).orElseThrow();
            Usuario autor = usuarioRepository.findByUsername((String) payload.get("username")).orElseThrow();

            MensajeForo.MensajeForoBuilder builder = MensajeForo.builder()
                    .contenido((String) payload.get("contenido"))
                    .foro(foro)
                    .autor(autor);

            if (payload.get("respuestaAId") != null) {
                Long rId = Long.valueOf(payload.get("respuestaAId").toString());
                mensajeRepository.findById(rId).ifPresent(builder::respuestaA);
            }

            mensajeRepository.save(builder.build());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al enviar: " + e.getMessage());
        }
    }

    @DeleteMapping("/mensajes/{id}")
    public ResponseEntity<?> eliminarMensaje(@PathVariable Long id) {
        MensajeForo mensaje = mensajeRepository.findById(id).orElseThrow();
        
        List<MensajeForo> respuestas = mensajeRepository.findAll().stream()
                .filter(m -> m.getRespuestaA() != null && m.getRespuestaA().getId().equals(id))
                .toList();
        
        for (MensajeForo r : respuestas) {
            r.setRespuestaA(null);
            mensajeRepository.save(r);
        }

        mensajeRepository.delete(mensaje);
        return ResponseEntity.ok().build();
    }
}