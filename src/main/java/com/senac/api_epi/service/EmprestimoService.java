package com.senac.api_epi.service;

import com.senac.api_epi.entities.Emprestimo;
import com.senac.api_epi.entities.Epi;
import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.EmprestimoRepository;
import com.senac.api_epi.repositories.EpiRepository;
import com.senac.api_epi.repositories.FuncionarioRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class EmprestimoService {

    private final EmprestimoRepository emprestimoRepository;
    private final FuncionarioRepository funcionarioRepository;
    private final EpiRepository epiRepository;

    public EmprestimoService(
            EmprestimoRepository emprestimoRepository,
            FuncionarioRepository funcionarioRepository,
            EpiRepository epiRepository) {
        this.emprestimoRepository = emprestimoRepository;
        this.funcionarioRepository = funcionarioRepository;
        this.epiRepository = epiRepository;
    }

    public Emprestimo solicitar(Emprestimo pedido) {
        // 1. O app enviou o funcionário e o EPI com id?
        if (pedido.getFuncionario() == null
                || pedido.getFuncionario().getId() == null
                || pedido.getEpi() == null
                || pedido.getEpi().getId() == null) {
            throw new IllegalArgumentException("Informe o funcionário e o EPI");
        }

        // 2. O pedido chega só com os ids: busca os dados completos no banco
        Funcionario funcionario = funcionarioRepository
                .findById(pedido.getFuncionario().getId())
                .orElseThrow(() -> new IllegalArgumentException("Funcionário não encontrado"));

        Epi epi = epiRepository
                .findById(pedido.getEpi().getId())
                .orElseThrow(() -> new IllegalArgumentException("EPI não encontrado"));

        // 3. Regras de negócio (NR-06)
        if (epi.isCaVencido()) {
            throw new IllegalArgumentException("EPI com CA vencido não pode ser emprestado");
        }

        if (epi.getQuantidadeDisponivel() <= 0) {
            throw new IllegalArgumentException("EPI sem estoque disponível");
        }

        boolean jaSolicitou = emprestimoRepository.existsByFuncionarioIdAndEpiIdAndStatus(
                funcionario.getId(), epi.getId(), "SOLICITADO");

        if (jaSolicitou) {
            throw new IllegalArgumentException("Você já tem uma solicitação aberta para este EPI");
        }

        // Desafio extra: impede novo pedido se o funcionário já estiver com o EPI emprestado
        boolean jaEmprestado = emprestimoRepository.existsByFuncionarioIdAndEpiIdAndStatus(
                funcionario.getId(), epi.getId(), "EMPRESTADO");

        if (jaEmprestado) {
            throw new IllegalArgumentException("Você já está com este EPI emprestado e ainda não o devolveu");
        }

        // 4. A API decide estes campos (não confiamos no que veio do app)
        pedido.setId(null); // sempre um registro novo
        pedido.setFuncionario(funcionario); // troca "só o id" pelo objeto completo
        pedido.setEpi(epi);
        pedido.setDataEmprestimo(LocalDate.now());
        pedido.setDataDevolucao(null);
        pedido.setStatus("SOLICITADO");

        // 5. Grava na tabela emprestimo
        return emprestimoRepository.save(pedido);
    }

    public List<Emprestimo> listarPorFuncionario(Long funcionarioId) {
        return emprestimoRepository.findByFuncionarioIdOrderByIdDesc(funcionarioId);
    }
}