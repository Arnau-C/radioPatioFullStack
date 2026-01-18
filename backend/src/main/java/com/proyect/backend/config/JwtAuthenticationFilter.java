package com.proyect.backend.config;

import com.proyect.backend.service.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;


//Función: Intercepta CADA petición que llega.
//¿Trae token? -> Lo revisa con JwtService.
//¿Es válido? -> Te deja pasar al Controller.
//¿No trae o es falso? -> Te bloquea (403 Forbidden).

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    // Este método se ejecuta CADA VEZ que alguien llama a la API
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain

    ) throws ServletException, IOException {

        // Buscamos el token en la cabecera de la petición (Header)
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userEmail;

        // Comprobación rápida: ¿Tiene token? ¿Empieza por "Bearer "?
        // Si no tiene token, le dejamos pasar al siguiente filtro (ya se encargará otro de rechazarlo si es necesario)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Extraemos el token (quitamos la palabra "Bearer " del principio)
        jwt = authHeader.substring(7);

        // Extraemos el usuario del token usando tu máquina 'JwtService'
        userEmail = jwtService.extractUsername(jwt);

        // Si hay usuario y NO está ya autenticado en el sistema...
        if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            
            // Buscamos sus datos en la base de datos
            UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);

            // Validamos el token: ¿Es válido? ¿No ha caducado?
            if (jwtService.isTokenValid(jwt, userDetails)) {
                
                // Si es válido, creamos un "Pase de Seguridad" oficial
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                
                // Añadimos detalles técnicos (IP, sesión, etc.)
                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );

                // ¡FINALMENTE! Le decimos a Spring Security: "Este usuario es legal, déjalo pasar"
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        
        // Pasamos el testigo al siguiente filtro
        filterChain.doFilter(request, response);
    }
}