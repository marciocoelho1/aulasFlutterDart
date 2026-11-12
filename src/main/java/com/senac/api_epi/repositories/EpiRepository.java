package com.senac.api_epi.repositories;
import com.senac.api_epi.entities.Epi;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;

public interface EpiRepository extends JpaRepository<Epi, Long> {

    // Quantos EPIs têm a validade do CA antes da data
    long countByValidadeCaBefore(LocalDate data);

    // NOVO na Aula 7 (exercício 2): EPIs com o estoque baixo
    long countByQuantidadeDisponivelLessThanEqual(int limite);
}