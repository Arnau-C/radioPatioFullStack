package com.proyect.backend.controller;

import com.proyect.backend.dto.ComunidadRequest;
import com.proyect.backend.model.Comunidad;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.ComunidadRepository;
import com.proyect.backend.repository.UsuarioRepository;
import com.proyect.backend.service.InvitationService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/api/comunidades")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor

public class ComunidadController {

    private final ComunidadRepository comunidadRepository;
    private final UsuarioRepository usuarioRepository;
    private final InvitationService invitationService;

    @PostMapping("/crear")
    public ResponseEntity<?> crearComunidad(@RequestBody ComunidadRequest request) {
        // 1. Buscamos al usuario (el creador será el presidente)
        Usuario presidente = usuarioRepository.findByUsername(request.getPresidenteUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        if(presidente.getComunidad() != null){
            return ResponseEntity.badRequest().body("Este usuario ya pertenece a una comunidad");
        }        
        // 2. Creamos la Comunidad (SIN CÓDIGO)
        Comunidad nuevaComunidad = Comunidad.builder()
                .nombre(request.getNombre())
                .direccion(request.getDireccion()) // Asegúrate de que en el DTO se llame getDireccion
                .presidente(presidente)
                .fechaCreacion(LocalDateTime.now())
                .build();

        // 3. Guardamos
        Comunidad comunidadCreada = comunidadRepository.save(nuevaComunidad);
        String codigo = invitationService.generarCodigoComunidad(comunidadCreada.getId());

        presidente.setComunidad(comunidadCreada);
        presidente.setRol("PRESIDENTE");
        usuarioRepository.save(presidente);

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Comunidad creada con éxito");
        respuesta.put("codigoInvitacion", codigo);
        respuesta.put("idComunidad", comunidadCreada.getId());

        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/unirse")
    public ResponseEntity<?> unirseComunidad(@RequestBody Map<String, String> request) {
        String codigo = request.get("codigo");
        String username = request.get("username");
        
        try{
            Comunidad comunidad = invitationService.validarCodigo(codigo);

            Usuario usuario = usuarioRepository.findByUsername(username).orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

            if (usuario.getComunidad() != null) {
                return ResponseEntity.status(400).body("Error: Ya perteneces a la comunidad '" + usuario.getComunidad().getNombre() + "'");
            }

            usuario.setComunidad(comunidad);
            usuario.setRol("VECINO");
            usuarioRepository.save(usuario);

            return ResponseEntity.ok(Map.of(
                "comunidadNombre", comunidad.getNombre(),
                "rolAsignado", "VECINO"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/detalle/{username}")
    public ResponseEntity<?> getDetalleComunidad(@PathVariable String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        if (usuario.getComunidad() == null) {
            return ResponseEntity.notFound().build();
        }

        // Devolvemos el código y el nombre para pintarlos en Flutter
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("nombre", usuario.getComunidad().getNombre());
        respuesta.put("codigoInvitacion", usuario.getComunidad().getCodigoInvitacion());
        
        return ResponseEntity.ok(respuesta);
    }
}