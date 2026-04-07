package com.proyect.backend.controller;

import com.proyect.backend.dto.RegisterRequest;
import com.proyect.backend.dto.UserUpdateRequest;
import com.proyect.backend.model.Usuario;
import com.proyect.backend.repository.UsuarioRepository;
import com.proyect.backend.service.AuthService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;


//Controlador REST para operaciones de Super Admin: listar, eliminar y modificar usuarios.

@RestController
@RequestMapping("/api/superadmin")
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('SUPER_ADMIN')") // <--- SOLO ENTRA EL SUPER ADMIN
public class SuperAdminController {

    private final UsuarioRepository repository;
    private final AuthService authService;

    //LISTAR TODOS LOS USUARIOS
    @GetMapping("/users")
    public ResponseEntity<List<Usuario>> getAllUsers() {
        List<Usuario> usuarios = repository.findAll();
        for (Usuario u : usuarios) {
        u.setLogs(null);      // <--- IMPORTANTE: No enviamos los logs al listado
        u.setComunidad(null); // <--- IMPORTANTE: Evitamos bucles con la comunidad
    }
    
    return ResponseEntity.ok(usuarios);
    }

    // ELIMINAR USUARIO
    @DeleteMapping("/users/{username}")
    public ResponseEntity<String> deleteUser(@PathVariable String username) {
        if (username.equals("superadmin")) {
            throw new IllegalArgumentException("No puedes eliminar al Super Admin principal");
        }
        
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
        
        // jpaRepository delete
        repository.delete(user);
        
        return ResponseEntity.ok("Usuario eliminado correctamente");
    }

    // MODIFICAR (Bloquear/Desbloquear/Rol)
    @PutMapping("/users/{username}")
    public ResponseEntity<Usuario> updateUser(
            @PathVariable String username,
            @RequestBody UserUpdateRequest request) {
        
        Usuario user = repository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        // Modificar datos básicos
        if (request.getNombre() != null) user.setNombre(request.getNombre());
        if (request.getApellidos() != null) user.setApellidos(request.getApellidos());
        if (request.getEmail() != null) user.setEmail(request.getEmail());
        
        // Modificar Rol
        if (request.getRol() != null) {
            user.setRol(request.getRol());
        }

        // LÓGICA DE DESBLOQUEO / BLOQUEO
        if (request.getCuentaBloqueada() != null) {
            user.setCuentaBloqueada(request.getCuentaBloqueada());
            // Si lo estamos desbloqueando (false), reseteamos los intentos a 0
            if (!request.getCuentaBloqueada()) {
                user.setIntentosFallidos(0);
            }
        }

        return ResponseEntity.ok(repository.save(user));
    }
    @PostMapping("/users/create")
    public ResponseEntity<String> createUser(@RequestBody RegisterRequest request) {
        authService.registerByAdmin(request);
        return ResponseEntity.ok("Usuario creado correctamente");
    }
    
}