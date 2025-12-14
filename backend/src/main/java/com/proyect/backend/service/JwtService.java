package com.proyect.backend.service;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;


//Función:
//Crea el Token JWT (la cadena larga de letras y números) cuando te logueas.
//Verifica si un Token es falso o ha caducado.
//Extrae el usuario de dentro del Token

@Service
public class JwtService {
    // Lógica relacionada con JWT (generación, validación, etc.) iría aquí
    private static final String SECRET_KEY = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    public String generateToken(UserDetails userDetails) {
        // Implementación de generación de token JWT
        return generateToken(new HashMap<>(), userDetails);
    }
        public String generateToken(Map<String, Object> extraClaims,UserDetails userDetails) {
            return Jwts
                .builder() // constructor del token
                .setClaims(extraClaims) //añade reclamos adicionales si los hay
                .setSubject(userDetails.getUsername()) //esto pone el nombre de usuario en el token (carnet de identidad)
                .setIssuedAt(new Date(System.currentTimeMillis())) //fecha de emisión
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 24 * 7)) //fecha de expiración (7 días)
                .signWith(getSignInKey(), SignatureAlgorithm.HS256) //firma el token con la clave secreta
                .compact(); //devuelve el token como cadena
        }

        //Comprueba si el token es válido para el usuario dado y si no ha caducado
        public boolean isTokenValid(String token, UserDetails userDetails) {
            final String username = extractUsername(token);
            return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
        }
        // 4. LEER EL TOKEN (Sacar datos del carnet)
        public String extractUsername(String token) {
            return extractClaim(token, Claims::getSubject);
        }
        private boolean isTokenExpired(String token) {
            return extractExpiration(token).before(new Date());
        }

        private Date extractExpiration(String token) {
            return extractClaim(token, Claims::getExpiration);
        }

        public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
            final Claims claims = extractAllClaims(token);
            return claimsResolver.apply(claims);
        }

        private Claims extractAllClaims(String token) {
            return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        }

        // Método auxiliar para decodificar tu clave secreta
        private Key getSignInKey() {
            byte[] keyBytes = Decoders.BASE64.decode(SECRET_KEY);
            return Keys.hmacShaKeyFor(keyBytes);
        }
}
