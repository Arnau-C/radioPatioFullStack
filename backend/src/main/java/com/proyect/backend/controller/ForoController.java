package com.proyect.backend.controller;

import com.proyect.backend.dto.MensajeDTO;
import com.proyect.backend.model.*;
import com.proyect.backend.repository.*;
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
        List<MensajeDTO> lista = mensajeRepository.findByForoIdOrderByFechaEnvioAsc(foroId).stream()
                .map(m -> MensajeDTO.builder()
                        .id(m.getId())
                        .contenido(m.getContenido())
                        .autorNombre(m.getAutor().getNombre() + " " + m.getAutor().getApellidos())
                        .autorUsername(m.getAutor().getUsername())
                        .fechaEnvio(m.getFechaEnvio())
                        .destacado(m.isDestacado()) // <--- AHORA SE ENVÍA ESTO
                        .respuestaAId(m.getRespuestaA() != null ? m.getRespuestaA().getId() : null)
                        .respuestaAContenido(m.getRespuestaA() != null ? m.getRespuestaA().getContenido() : null)
                        .respuestaAAutor(m.getRespuestaA() != null ? m.getRespuestaA().getAutor().getNombre() : null)
                        .build())
                .toList();
        return ResponseEntity.ok(lista);
    }

    @PostMapping("/{foroId}/mensajes")
    public ResponseEntity<?> enviarMensaje(@PathVariable Long foroId, @RequestBody Map<String, Object> payload) {
        try {
            Foro foro = foroRepository.findById(foroId).orElseThrow();
            Usuario autor = usuarioRepository.findByUsername((String) payload.get("username")).orElseThrow();

            MensajeForo mensaje = MensajeForo.builder()
                    .contenido((String) payload.get("contenido"))
                    .foro(foro)
                    .autor(autor)
                    .build();

            if (payload.get("respuestaAId") != null) {
                Long rId = Long.valueOf(payload.get("respuestaAId").toString());
                mensajeRepository.findById(rId).ifPresent(mensaje::setRespuestaA);
            }

            mensajeRepository.save(mensaje);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al enviar");
        }
    }

    @DeleteMapping("/mensajes/{id}")
    public ResponseEntity<?> eliminarMensaje(@PathVariable Long id) {
        MensajeForo objetivo = mensajeRepository.findById(id).orElseThrow();
        
        // LIMPIEZA DE HIJOS: Si otros mensajes responden a este, les quitamos la referencia
        // para que la base de datos no dé error de "Foreign Key"
        mensajeRepository.findAll().stream()
            .filter(m -> m.getRespuestaA() != null && m.getRespuestaA().getId().equals(id))
            .forEach(hijo -> {
                hijo.setRespuestaA(null);
                mensajeRepository.save(hijo);
            });

        mensajeRepository.delete(objetivo);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/mensajes/{id}/destacar")
    public ResponseEntity<?> toggleDestacar(@PathVariable Long id) {
        MensajeForo m = mensajeRepository.findById(id).orElseThrow();
        m.setDestacado(!m.isDestacado());
        mensajeRepository.save(m);
        return ResponseEntity.ok().build();
    }
}