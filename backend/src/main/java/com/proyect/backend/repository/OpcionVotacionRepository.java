package com.proyect.backend.repository;

import com.proyect.backend.model.OpcionVotacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OpcionVotacionRepository extends JpaRepository<OpcionVotacion, Long> {

    List<OpcionVotacion> findByVotacionId(Long votacionId);
}
