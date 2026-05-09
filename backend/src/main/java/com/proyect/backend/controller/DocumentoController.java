package com.proyect.backend.controller;

import com.proyect.backend.model.Carpeta;
import com.proyect.backend.model.Documento;
import com.proyect.backend.service.DocumentoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/api/documentos")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentoController {

    private final DocumentoService documentoService;

    // --- CARPETAS ---

    @GetMapping("/carpetas/{comunidadNombre}")
    public ResponseEntity<List<Carpeta>> getCarpetas(@PathVariable String comunidadNombre) {
        // Usa el servicio para obtener las carpetas de la comunidad
        return ResponseEntity.ok(documentoService.obtenerCarpetas(comunidadNombre));
    }

    @PostMapping("/carpetas")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> crearCarpeta(@RequestBody Map<String, String> payload) {
        try {
            // Crea una nueva carpeta usando el servicio
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
            // Lógica para renombrar carpetas en el servicio
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
            // Lógica para borrar carpetas (valida que no tengan PDFs)
            documentoService.borrarCarpeta(id);
            return ResponseEntity.ok(Map.of("mensaje", "Carpeta borrada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // --- DOCUMENTOS ---

    @GetMapping("/carpeta/{carpetaId}")
    public ResponseEntity<List<Documento>> getDocumentos(@PathVariable Long carpetaId) {
        // Obtiene la lista de PDFs de una carpeta específica
        return ResponseEntity.ok(documentoService.obtenerDocumentosPorCarpeta(carpetaId));
    }

    @PostMapping("/subir")
    public CompletableFuture<ResponseEntity<?>> subirArchivo(
            @RequestParam("file") MultipartFile file,
            @RequestParam("carpetaId") Long carpetaId,
            @RequestParam("username") String username) throws IOException {
        
        return documentoService.subirDocumento(file, carpetaId, username)
                // Usamos <ResponseEntity<?>> para que Java acepte cualquier tipo de respuesta
                .<ResponseEntity<?>>thenApply(doc -> ResponseEntity.ok(doc))
                .exceptionally(ex -> ResponseEntity.status(500).body(Map.of("error", ex.getMessage())));
    }

    @GetMapping("/descargar/{id}")
    public ResponseEntity<StreamingResponseBody> descargarDocumento(@PathVariable Long id) {
        // Buscamos el documento por ID para obtener la ruta del archivo físico
        Documento doc = documentoService.obtenerDocumentoPorId(id);
        File file = new File(doc.getRutaArchivo()); // Usa rutaArchivo del modelo

        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        // Enviamos el PDF en "streaming" para ahorrar memoria RAM en el servidor
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
                // "inline" permite que el navegador abra el visor de PDF directamente
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + doc.getTitulo() + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(responseBody);
    }

    @PutMapping("/mover/{docId}")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> moverDocumento(@PathVariable Long docId, @RequestBody Map<String, Long> payload) {
        try {
            // Lógica para mover un archivo de una carpeta a otra
            documentoService.moverDocumento(docId, payload.get("nuevaCarpetaId"));
            return ResponseEntity.ok(Map.of("mensaje", "Documento movido"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('PRESIDENTE')")
    public ResponseEntity<?> borrarDocumento(@PathVariable Long id) {
        try {
            // Borra el archivo físico y el registro en la base de datos
            documentoService.borrarDocumento(id);
            return ResponseEntity.ok(Map.of("mensaje", "Archivo borrado correctamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}