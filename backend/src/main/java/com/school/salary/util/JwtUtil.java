package com.school.salary.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class JwtUtil {

    private final SecretKey key;
    private final long expireSeconds;

    public JwtUtil(String secret, long expireSeconds) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expireSeconds = expireSeconds;
    }

    public String generateToken(Long userId, String username, String role, Long campusId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", role);
        claims.put("campusId", campusId);

        Date now = new Date();
        Date expire = new Date(now.getTime() + expireSeconds * 1000L);

        return Jwts.builder()
                .claims(claims)
                .issuedAt(now)
                .expiration(expire)
                .signWith(key)
                .compact();
    }

    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean validateToken(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (Exception e) {
            log.warn("JWT 验证失败: {}", e.getMessage());
            return false;
        }
    }

    public Long getUserId(String token) {
        Claims claims = parseClaims(token);
        Object userId = claims.get("userId");
        return userId != null ? ((Number) userId).longValue() : null;
    }

    public String getUsername(String token) {
        Claims claims = parseClaims(token);
        return claims.get("username", String.class);
    }

    public String getRole(String token) {
        Claims claims = parseClaims(token);
        return claims.get("role", String.class);
    }

    public Long getCampusId(String token) {
        Claims claims = parseClaims(token);
        Object campusId = claims.get("campusId");
        return campusId != null ? ((Number) campusId).longValue() : null;
    }
}
