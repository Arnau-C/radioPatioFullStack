package com.proyect.backend.controller;

import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/registro")
    public ResponseEntity<?> registrarUsuario(@RequestBody Usuario usuario) {
        try {
            // Validaciones básicas
            if (usuario.getUsername() == null || usuario.getUsername().isEmpty() ||                 
                usuario.getPassword() == null || usuario.getPassword().isEmpty() ||
                usuario.getEmail() == null || usuario.getEmail().isEmpty()) {
                return ResponseEntity.badRequest().body("Faltan datos obligatorios");
            }

            if (usuarioRepository.existsById(usuario.getUsername())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Error: El usuario ya existe");
            }

            // 2. COMPROBAR EMAIL
            if (usuarioRepository.existsByEmail(usuario.getEmail())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Error: El email ya está registrado");
            }

            // Encriptar y defaults
            usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
            if (usuario.getRol() == null) usuario.setRol("USER");
            usuario.setIntentosFallidos(0);
            usuario.setCuentaBloqueada(false);

            // Guardar
            usuarioRepository.save(usuario);

            return ResponseEntity.status(HttpStatus.CREATED).body("Usuario registrado con éxito");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    @DeleteMapping("/borrar/{username}") // ESTO ES LO QUE HAY QUE MERGEAR ERIC
    public ResponseEntity<?> eliminarUsuarioDeEmergencia(@PathVariable String username) {
        

        try {
            if (!usuarioRepository.existsById(username)) {
                System.out.println("No encuentro a: " + username);
                return ResponseEntity.notFound().build();
            }

            usuarioRepository.deleteById(username);
            System.out.println("Borrando a: " + username);
            return ResponseEntity.ok("Usuario eliminado correctamente");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }

} 
