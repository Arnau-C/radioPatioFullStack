package com.proyect.backend.controller;

import com.proyect.backend.dto.ComunidadRequest;
import com.proyect.backend.model.*; // Importamos Foro
import com.proyect.backend.repository.*; // Importamos ForoRepository
import com.proyect.backend.service.ComunidadService;
import com.proyect.backend.service.InvitationService;
import com.proyect.backend.dto.PermisosVecinoRequest;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/comunidades")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ComunidadController {

    private final ComunidadRepository comunidadRepository;
    private final UsuarioRepository usuarioRepository;
    private final InvitationService invitationService;
    private final ComunidadService comunidadService;
    private final ForoRepository foroRepository; // <--- AÑADIDO PARA EL FORO

   @PostMapping("/crear")
public ResponseEntity<?> crearComunidad(@RequestBody ComunidadRequest request) {
    // 1. Buscamos al usuario (el creador será el presidente)
    Usuario presidente = usuarioRepository.findByUsername(request.getPresidenteUsername())
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

    if(presidente.getComunidad() != null){
        return ResponseEntity.badRequest().body("Este usuario ya pertenece a una comunidad");
    }        

    // 2. Creamos la Comunidad física en la DB
    Comunidad nuevaComunidad = Comunidad.builder()
            .nombre(request.getNombre())
            .direccion(request.getDireccion())
            .presidente(presidente)
            .fechaCreacion(LocalDateTime.now())
            .build();

    Comunidad comunidadCreada = comunidadRepository.save(nuevaComunidad);

    // 3. CREAMOS EL FORO ÚNICO (Solo una vez)
    Foro foroComunidad = Foro.builder()
            .titulo("Foro Vecinal - " + comunidadCreada.getNombre())
            .descripcion("Chat oficial de comunicación interna")
            .comunidad(comunidadCreada) 
            .fechaCreacion(LocalDateTime.now())
            .build();
    
    foroRepository.save(foroComunidad);

    // 4. Lógica de invitación y roles
    String codigo = invitationService.generarCodigoComunidad(comunidadCreada.getId());

    presidente.setComunidad(comunidadCreada);
    presidente.setRol("PRESIDENTE");
    usuarioRepository.save(presidente);

    // 5. Respuesta JSON
    Map<String, Object> respuesta = new HashMap<>();
    respuesta.put("mensaje", "Comunidad creada con éxito");
    respuesta.put("codigoInvitacion", codigo);
    respuesta.put("idComunidad", comunidadCreada.getId());
    respuesta.put("foroId", foroComunidad.getId());

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

          Long foroId = foroRepository.findByComunidadId(comunidad.getId())
                    .map(Foro::getId)
                    .orElse(null);

            return ResponseEntity.ok(Map.of(
                "comunidadNombre", comunidad.getNombre(),
                "rolAsignado", "VECINO",
                "foroId", foroId 
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
        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("id", usuario.getComunidad().getId());respuesta.put("id", usuario.getComunidad().getId());
        
        respuesta.put("nombre", usuario.getComunidad().getNombre());
        respuesta.put("codigoInvitacion", usuario.getComunidad().getCodigoInvitacion());
        
        return ResponseEntity.ok(respuesta);
    }

    @GetMapping("/{comunidadId}/miembros")
    public ResponseEntity<List<Usuario>> obtenerMiembros(@PathVariable Long comunidadId) {
        // En tu servicio tendrás que llamar a usuarioRepository.findByComunidadId(comunidadId)
        List<Usuario> miembros = comunidadService.obtenerMiembros(comunidadId);
        return ResponseEntity.ok(miembros);
    }

    @PutMapping("/{comunidadId}/miembros/{usernameExpulsado}/expulsar")
    public ResponseEntity<Void> expulsarMiembro(
            @PathVariable Long comunidadId,
            @PathVariable String usernameExpulsado,
            Authentication authentication) {
        
        String usernamePresidente = authentication.getName();
        comunidadService.expulsarMiembro(comunidadId, usernameExpulsado, usernamePresidente);
        
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{comunidadId}/miembros/{usernameVecino}/permisos")
    public ResponseEntity<?> actualizarPermisos(
            @PathVariable Long comunidadId,
            @PathVariable String usernameVecino,
            @RequestBody PermisosVecinoRequest request,
            Authentication authentication) {
        
        String usernamePresidente = authentication.getName(); // Saca quién está logueado
        
        System.out.println("PERMISOS RECIBIDOS PARA " + usernameVecino + " -> Avisos: " + request.isPermisoCrearAvisos() + ", Docs: " + request.isPermisoGestionarDocumentos());
        
        try {
            comunidadService.actualizarPermisosVecino(
                comunidadId, 
                usernameVecino, 
                usernamePresidente, 
                request.isPermisoCrearAvisos(), 
                request.isPermisoGestionarDocumentos()
            );
            return ResponseEntity.ok(Map.of("mensaje", "Permisos actualizados correctamente"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
}