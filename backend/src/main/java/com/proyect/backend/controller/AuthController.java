package com.proyect.backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.proyect.backend.dto.LoginRequest;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("/api/auth")
public class AuthController {
    /*@PostMapping("path")
    public ResponseEntity<Map<String,String>> login(@RequestBody LoginRequest request) {
        //TODO: process POST request
        Map<String, String> response = new HashMap<>();
        
        return entity;
    }*/
    
}
