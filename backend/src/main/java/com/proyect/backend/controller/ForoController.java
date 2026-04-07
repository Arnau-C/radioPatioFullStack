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
                        .destacado(m.isDestacado()) // <--- AHORA SÍ SE ENVÍA A LA WEB
                        .respuestaAId(m.getRespuestaA() != null ? m.getRespuestaA().getId() : null)
                        .respuestaAContenido(m.getRespuestaA() != null ? m.getRespuestaA().getContenido() : null)
                        .respuestaAAutor(m.getRespuestaA() != null ? m.getRespuestaA().getAutor().getNombre() : null)
                        .build())
                .toList();
        return ResponseEntity.ok(mensajes);
    }

    @DeleteMapping("/mensajes/{id}")
    public ResponseEntity<?> eliminarMensaje(@PathVariable Long id) {
        // 1. Buscamos el mensaje
        MensajeForo mensaje = mensajeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Mensaje no encontrado"));
        
        // 2. IMPORTANTE: Buscamos todos los mensajes que son respuestas a este
        // y les quitamos la referencia (ponemos respuesta_a_id a null)
        List<MensajeForo> respuestas = mensajeRepository.findAll().stream()
                .filter(m -> m.getRespuestaA() != null && m.getRespuestaA().getId().equals(id))
                .toList();
        
        for (MensajeForo r : respuestas) {
            r.setRespuestaA(null);
            mensajeRepository.save(r);
        }

        // 3. Ahora que nadie lo referencia, podemos borrarlo sin error de SQL
        mensajeRepository.delete(mensaje);
        return ResponseEntity.ok().build();
    }
    
}