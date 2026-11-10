package com.senac.api_epi.repositories;

import com.senac.api_epi.entities.TreinamentoRealizado;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TreinamentoRealizadoRepository
    extends JpaRepository<TreinamentoRealizado, Long> {

    // Treinamentos que um funcionário já concluiu (mais recente primeiro)
    List<TreinamentoRealizado> findByFuncionarioIdOrderByDataConclusaoDesc(Long funcionarioId);

    // Última conclusão de um treinamento específico (usada para checar vencimento)
    Optional<TreinamentoRealizado> findFirstByFuncionarioIdAndTreinamentoIdOrderByDataConclusaoDesc(
            Long funcionarioId,
            Long treinamentoId
    );

    // Este funcionário já concluiu este treinamento?
    boolean existsByFuncionarioIdAndTreinamentoId(
            Long funcionarioId,
            Long treinamentoId
    );
}
