package com.proyect.backend.repository;

import com.proyect.backend.model.LoginLog;
import org.springframework.data.jpa.repository.JpaRepository;

// Repositorio para gestionar los logs de intentos de login
public interface LoginLogRepository extends JpaRepository<LoginLog, Long> {
    
}