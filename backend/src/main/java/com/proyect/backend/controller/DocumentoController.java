package com.proyect.backend.controller;

import com.proyect.backend.model.Carpeta;
import com.proyect.backend.model.Documento;
import com.proyect.backend.service.DocumentoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/documentos")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentoController {

    private final DocumentoService documentoService;

    // --- CARPETAS ---

    @GetMapping("/carpetas/{comunidadNombre}")
    public ResponseEntity<List<Carpeta>> getCarpetas(@PathVariable String comunidadNombre) {
        return ResponseEntity.ok(documentoService.obtenerCarpetas(comunidadNombre));
    }

    @PostMapping("/carpetas")
    public ResponseEntity<?> crearCarpeta(@RequestBody Map<String, String> payload) {
        try {
            Carpeta c = documentoService.crearCarpeta(
                payload.get("nombre"), 
                payload.get("comunidadNombre"), 
                payload.get("username")
            );
            return ResponseEntity.ok(c);
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/carpetas/{id}")
    public ResponseEntity<?> renombrarCarpeta(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        try {
            documentoService.renombrarCarpeta(id, payload.get("nuevoNombre"), payload.get("username"));
            return ResponseEntity.ok(Map.of("mensaje", "Carpeta renombrada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/carpetas/{id}")
    public ResponseEntity<?> borrarCarpeta(@PathVariable Long id, @RequestParam String username) {
        try {
            documentoService.borrarCarpeta(id, username);
            return ResponseEntity.ok(Map.of("mensaje", "Carpeta borrada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }

    // --- DOCUMENTOS ---

    @GetMapping("/carpeta/{carpetaId}")
    public ResponseEntity<List<Documento>> getDocumentos(@PathVariable Long carpetaId) {
        return ResponseEntity.ok(documentoService.obtenerDocumentosPorCarpeta(carpetaId));
    }

    @PostMapping("/subir")
    public ResponseEntity<?> subirArchivo(
            @RequestParam("file") MultipartFile file,
            @RequestParam("carpetaId") Long carpetaId,
            @RequestParam("username") String username) {
        try {
            byte[] fileBytes = file.getBytes();
            String originalFilename = file.getOriginalFilename();
            String contentType = file.getContentType();

            Documento doc = documentoService.subirDocumento(fileBytes, originalFilename, contentType, carpetaId, username).join();
            return ResponseEntity.ok(doc);
        } catch (Exception ex) {
            return ResponseEntity.status(403).body(Map.of("error", ex.getMessage()));
        }
    }

    @GetMapping("/descargar/{id}")
    public ResponseEntity<StreamingResponseBody> descargarDocumento(@PathVariable Long id) {
        Documento doc = documentoService.obtenerDocumentoPorId(id);
        File file = new File(doc.getRutaArchivo());

        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        StreamingResponseBody responseBody = outputStream -> {
            try (InputStream inputStream = new FileInputStream(file)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, length);
                }
            }
        };

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + doc.getTitulo() + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(responseBody);
    }

    @PutMapping("/mover/{docId}")
    public ResponseEntity<?> moverDocumento(@PathVariable Long docId, @RequestBody Map<String, Object> payload) {
        try {
            Long nuevaCarpetaId = Long.valueOf(payload.get("nuevaCarpetaId").toString());
            String username = payload.get("username").toString();
            documentoService.moverDocumento(docId, nuevaCarpetaId, username);
            return ResponseEntity.ok(Map.of("mensaje", "Documento movido"));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> borrarDocumento(@PathVariable Long id, @RequestParam String username) {
        try {
            documentoService.borrarDocumento(id, username);
            return ResponseEntity.ok(Map.of("mensaje", "Archivo borrado correctamente"));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }
}