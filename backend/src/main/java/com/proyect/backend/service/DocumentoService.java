package com.proyect.backend.service;

import com.proyect.backend.model.*;
import com.proyect.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DocumentoService {

    private final DocumentoRepository documentoRepository;
    private final CarpetaRepository carpetaRepository;
    private final UsuarioRepository usuarioRepository;
    private final ComunidadRepository comunidadRepository;

    // Carpeta en tu servidor donde se guardarán físicamente los PDFs
    private final String UPLOAD_DIR = "uploads/pdfs/";

    // --- LÓGICA DE CARPETAS ---
    public List<Carpeta> obtenerCarpetas(String comunidadNombre) {
        Comunidad comunidad = comunidadRepository.findByNombre(comunidadNombre)
                .orElseThrow(() -> new RuntimeException("Comunidad no encontrada"));
        
        List<Carpeta> carpetas = carpetaRepository.findByComunidadId(comunidad.getId());
        
        // Si la comunidad no tiene la carpeta principal, se la creamos al vuelo
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

    public Carpeta crearCarpeta(String nombre, String comunidadNombre) {
        Comunidad comunidad = comunidadRepository.findByNombre(comunidadNombre).orElseThrow();
        Carpeta nueva = Carpeta.builder()
                .nombre(nombre)
                .esPrincipal(false)
                .comunidad(comunidad)
                .build();
        return carpetaRepository.save(nueva);
    }

    public void renombrarCarpeta(Long id, String nuevoNombre) {
        Carpeta carpeta = carpetaRepository.findById(id).orElseThrow();
        if (carpeta.isEsPrincipal()) throw new RuntimeException("No puedes renombrar la Carpeta Principal");
        carpeta.setNombre(nuevoNombre);
        carpetaRepository.save(carpeta);
    }

    public void borrarCarpeta(Long id) {
        Carpeta carpeta = carpetaRepository.findById(id).orElseThrow();
        if (carpeta.isEsPrincipal()) throw new RuntimeException("No puedes borrar la Carpeta Principal");
        // Aquí validamos lo que pediste:
        if (documentoRepository.existsByCarpetaId(id)) {
            throw new RuntimeException("No puedes borrar una carpeta que tiene PDFs. Mueve o borra los archivos primero.");
        }
        carpetaRepository.delete(carpeta);
    }
    public void borrarDocumento(Long id) {
    Documento doc = documentoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Documento no encontrado"));

    // 1. Intentar borrar el archivo físico del disco duro
    try {
        Path path = Paths.get(doc.getRutaArchivo());
        Files.deleteIfExists(path);
    } catch (IOException e) {
        System.err.println("Error al borrar el archivo físico: " + e.getMessage());
        // Seguimos adelante para al menos borrarlo de la BD
    }

    // 2. Borrar el registro de la Base de Datos
    documentoRepository.delete(doc);
}

    // --- LÓGICA DE DOCUMENTOS ---
    public Documento subirDocumento(MultipartFile file, Long carpetaId, String username) throws IOException {
        if (file.getContentType() == null || !file.getContentType().equals("application/pdf")) {
            throw new RuntimeException("Error: Solo se permite subir archivos PDF.");
        }

        Usuario usuario = usuarioRepository.findByUsername(username).orElseThrow();
        Carpeta carpeta = carpetaRepository.findById(carpetaId).orElseThrow();

        // 1. Crear directorio en el PC si no existe
        File directory = new File(UPLOAD_DIR);
        if (!directory.exists()) directory.mkdirs();

        // 2. Guardar archivo físico
        String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path filePath = Paths.get(UPLOAD_DIR + fileName);
        Files.write(filePath, file.getBytes());

        // 3. Guardar registro en Base de Datos
        Documento doc = Documento.builder()
                .titulo(file.getOriginalFilename())
                .rutaArchivo(filePath.toString())
                .carpeta(carpeta)
                .subidoPor(usuario)
                .comunidad(carpeta.getComunidad())
                .build();

        return documentoRepository.save(doc);
    }

    public List<Documento> obtenerDocumentosPorCarpeta(Long carpetaId) {
        return documentoRepository.findByCarpetaId(carpetaId);
    }

    public Documento obtenerDocumentoPorId(Long docId) {
        return documentoRepository.findById(docId).orElseThrow();
    }

    public void moverDocumento(Long docId, Long nuevaCarpetaId) {
        Documento doc = obtenerDocumentoPorId(docId);
        Carpeta nuevaCarpeta = carpetaRepository.findById(nuevaCarpetaId).orElseThrow();
        doc.setCarpeta(nuevaCarpeta);
        documentoRepository.save(doc);
    }
}