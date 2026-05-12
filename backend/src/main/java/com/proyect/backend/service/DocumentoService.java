package com.proyect.backend.service;

import com.proyect.backend.model.*;
import com.proyect.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
public class DocumentoService {

    private final DocumentoRepository documentoRepository;
    private final CarpetaRepository carpetaRepository;
    private final UsuarioRepository usuarioRepository;
    private final ComunidadRepository comunidadRepository;

    private final String UPLOAD_DIR = "uploads/pdfs/";

    // --- MÉTODO DE SEGURIDAD UNIFICADA ---
    private void validarPermisos(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        // Verificamos el Rol o el permiso específico
        boolean esPresidente = "PRESIDENTE".equals(usuario.getRol());
        boolean tienePermiso = usuario.isPermisoGestionarReservas(); 

        if (!esPresidente && !tienePermiso) {
            throw new RuntimeException("Acceso denegado: No tienes permisos administrativos.");
        }
    }

    // --- LÓGICA DE CARPETAS ---
    public List<Carpeta> obtenerCarpetas(String comunidadNombre) {
        Comunidad comunidad = comunidadRepository.findByNombre(comunidadNombre)
                .orElseThrow(() -> new RuntimeException("Comunidad no encontrada"));
        
        List<Carpeta> carpetas = carpetaRepository.findByComunidadId(comunidad.getId());
        
        if (carpetas.stream().noneMatch(Carpeta::isEsPrincipal)) {
            Carpeta principal = Carpeta.builder()
                    .nombre("Carpeta Principal")
                    .esPrincipal(true)
                    .comunidad(comunidad)
                    .build();
            carpetaRepository.save(principal);
            carpetas.add(principal);
        }
        return carpetas;
    }

    public Carpeta crearCarpeta(String nombre, String comunidadNombre, String username) {
        validarPermisos(username); //
        Comunidad comunidad = comunidadRepository.findByNombre(comunidadNombre)
                .orElseThrow(() -> new RuntimeException("Comunidad no encontrada"));
                
        Carpeta nueva = Carpeta.builder()
                .nombre(nombre)
                .esPrincipal(false)
                .comunidad(comunidad)
                .build();
        return carpetaRepository.save(nueva);
    }

    public void renombrarCarpeta(Long id, String nuevoNombre, String username) {
        validarPermisos(username); //
        Carpeta carpeta = carpetaRepository.findById(id).orElseThrow();
        if (carpeta.isEsPrincipal()) throw new RuntimeException("No puedes renombrar la Carpeta Principal");
        
        carpeta.setNombre(nuevoNombre);
        carpetaRepository.save(carpeta);
    }

    public void borrarCarpeta(Long id, String username) {
        validarPermisos(username); //
        Carpeta carpeta = carpetaRepository.findById(id).orElseThrow();
        if (carpeta.isEsPrincipal()) throw new RuntimeException("No puedes borrar la Carpeta Principal");
        
        if (documentoRepository.existsByCarpetaId(id)) {
            throw new RuntimeException("No puedes borrar una carpeta que tiene PDFs. Mueve o borra los archivos primero.");
        }
        carpetaRepository.delete(carpeta);
    }

    // --- LÓGICA DE DOCUMENTOS ---
    @Async
    public CompletableFuture<Documento> subirDocumento(byte[] fileBytes, String originalFilename, String contentType, Long carpetaId, String username) {
        try {
            validarPermisos(username); //

            if (contentType == null || !contentType.equals("application/pdf")) {
                throw new RuntimeException("Error: Solo se permite subir archivos PDF.");
            }

            Usuario usuario = usuarioRepository.findByUsername(username).orElseThrow();
            Carpeta carpeta = carpetaRepository.findById(carpetaId).orElseThrow();

            // Verificar pertenencia a comunidad
            if (!usuario.getComunidad().getId().equals(carpeta.getComunidad().getId())) {
                throw new RuntimeException("No perteneces a esta comunidad.");
            }

            File directory = new File(UPLOAD_DIR);
            if (!directory.exists()) directory.mkdirs();

            String fileName = System.currentTimeMillis() + "_" + originalFilename;
            Path filePath = Paths.get(UPLOAD_DIR + fileName);
            Files.write(filePath, fileBytes);

            Documento doc = Documento.builder()
                    .titulo(originalFilename)
                    .rutaArchivo(filePath.toString())
                    .carpeta(carpeta)
                    .subidoPor(usuario)
                    .comunidad(carpeta.getComunidad())
                    .build();

            return CompletableFuture.completedFuture(documentoRepository.save(doc));
            
        } catch (Exception e) {
            return CompletableFuture.failedFuture(e);
        }
    }

    public void borrarDocumento(Long id, String username) {
        validarPermisos(username); //
        Documento doc = documentoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Documento no encontrado"));

        try {
            Path path = Paths.get(doc.getRutaArchivo());
            Files.deleteIfExists(path);
        } catch (IOException e) {
            System.err.println("Error al borrar el archivo físico: " + e.getMessage());
        }

        documentoRepository.delete(doc);
    }

    public void moverDocumento(Long docId, Long nuevaCarpetaId, String username) {
        validarPermisos(username); //
        Documento doc = obtenerDocumentoPorId(docId);
        Carpeta nuevaCarpeta = carpetaRepository.findById(nuevaCarpetaId).orElseThrow();
        
        doc.setCarpeta(nuevaCarpeta);
        documentoRepository.save(doc);
    }

    public List<Documento> obtenerDocumentosPorCarpeta(Long carpetaId) {
        return documentoRepository.findByCarpetaId(carpetaId);
    }

    public Documento obtenerDocumentoPorId(Long docId) {
        return documentoRepository.findById(docId).orElseThrow();
    }
}