package com.senac.api_epi.repositories;
import com.senac.api_epi.entities.Epi;
import org.springframework.data.jpa.repository.JpaRepository;
public interface EpiRepository extends JpaRepository<Epi, Long> {
}