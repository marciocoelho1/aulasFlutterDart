package com.senac.api_epi.repositories;

import com.senac.api_epi.entities.TreinamentoRealizado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface TreinamentoRealizadoRepository
    extends JpaRepository<TreinamentoRealizado, Long> {

    // Treinamentos que um funcionário já concluiu (mais recente primeiro)
    List<TreinamentoRealizado> findByFuncionarioIdOrderByDataConclusaoDesc(Long funcionarioId);

    // Pares (funcionário, treinamento) concluídos, sem duplicar reciclagens.
    // Usado no cálculo de "treinamentos pendentes" do dashboard.
    @Query("select distinct r.funcionario.id, r.treinamento.id from TreinamentoRealizado r")
    List<Object[]> buscarParesDistintos();

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

    // O funcionário tem treinamentos concluídos? (bloqueia exclusão)
    boolean existsByFuncionarioId(Long funcionarioId);
}
