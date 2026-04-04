package com.proyect.backend.controller;

import com.proyect.backend.model.Carpeta;
import com.proyect.backend.model.Documento;
import com.proyect.backend.service.DocumentoService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/documentos")
@RequiredArgsConstructor
public class DocumentoController {

    private final DocumentoService documentoService;

    // --- ENDPOINTS CARPETAS ---
    @GetMapping("/carpetas/{comunidadNombre}")
    public ResponseEntity<List<Carpeta>> getCarpetas(@PathVariable String comunidadNombre) {
        return ResponseEntity.ok(documentoService.obtenerCarpetas(comunidadNombre));
    }

    @PostMapping("/carpetas")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> crearCarpeta(@RequestBody Map<String, String> payload) {
        try {
            Carpeta c = documentoService.crearCarpeta(payload.get("nombre"), payload.get("comunidadNombre"));
            return ResponseEntity.ok(c);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/carpetas/{id}")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> renombrarCarpeta(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        try {
            documentoService.renombrarCarpeta(id, payload.get("nuevoNombre"));
            return ResponseEntity.ok(Map.of("mensaje", "Carpeta renombrada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/carpetas/{id}")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> borrarCarpeta(@PathVariable Long id) {
        try {
            documentoService.borrarCarpeta(id);
            return ResponseEntity.ok(Map.of("mensaje", "Carpeta borrada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // --- ENDPOINTS DOCUMENTOS ---
    @GetMapping("/carpeta/{carpetaId}")
    public ResponseEntity<List<Documento>> getDocumentos(@PathVariable Long carpetaId) {
        return ResponseEntity.ok(documentoService.obtenerDocumentosPorCarpeta(carpetaId));
    }

    @PostMapping("/subir")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> subirDocumento(
            @RequestParam("file") MultipartFile file,
            @RequestParam("carpetaId") Long carpetaId,
            @RequestParam("username") String username) {
        try {
            Documento doc = documentoService.subirDocumento(file, carpetaId, username);
            return ResponseEntity.ok(doc);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/mover/{docId}")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> moverDocumento(@PathVariable Long docId, @RequestBody Map<String, Long> payload) {
        try {
            documentoService.moverDocumento(docId, payload.get("nuevaCarpetaId"));
            return ResponseEntity.ok(Map.of("mensaje", "Documento movido"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/descargar/{docId}")
    public ResponseEntity<Resource> descargarDocumento(@PathVariable Long docId) {
        try {
            Documento doc = documentoService.obtenerDocumentoPorId(docId);
            Path filePath = Paths.get(doc.getRutaArchivo());
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() || resource.isReadable()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_PDF)
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + doc.getTitulo() + "\"")
                        .body(resource);
            } else {
                throw new RuntimeException("No se pudo leer el archivo físico");
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @DeleteMapping("/{id}")
@PreAuthorize("hasAuthority('PRESIDENTE')")
public ResponseEntity<?> borrarDocumento(@PathVariable Long id) {
    try {
        documentoService.borrarDocumento(id);
        return ResponseEntity.ok(Map.of("mensaje", "Archivo borrado correctamente"));
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}
}