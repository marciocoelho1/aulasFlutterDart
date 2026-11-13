package com.senac.api_epi.service;

import com.senac.api_epi.repositories.*;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class DashboardService {

    private final EpiRepository epiRepository;
    private final EmprestimoRepository emprestimoRepository;
    private final FuncionarioRepository funcionarioRepository;
    private final TreinamentoRepository treinamentoRepository;
    private final TreinamentoRealizadoRepository realizadoRepository;
    private final AutorizacaoService autorizacaoService;

    public DashboardService(EpiRepository epiRepository,
                            EmprestimoRepository emprestimoRepository,
                            FuncionarioRepository funcionarioRepository,
                            TreinamentoRepository treinamentoRepository,
                            TreinamentoRealizadoRepository realizadoRepository,
                            AutorizacaoService autorizacaoService) {
        this.epiRepository = epiRepository;
        this.emprestimoRepository = emprestimoRepository;
        this.funcionarioRepository = funcionarioRepository;
        this.treinamentoRepository = treinamentoRepository;
        this.realizadoRepository = realizadoRepository;
        this.autorizacaoService = autorizacaoService;
    }

    public Map<String, Long> indicadores(Long adminId) {
        // Mesma regra de acesso dos outros serviços (aceita "Admin", "ADMIN", ...).
        autorizacaoService.exigirAdmin(adminId);

        // Treinamentos pendentes:
        // cada funcionário deve fazer todos os treinamentos.
        // 3 funcionários x 4 treinamentos = 12 obrigatórios - os já feitos.
        long funcionarios = funcionarioRepository.count();
        long treinamentos = treinamentoRepository.count();

        // Um treinamento refeito gera outro registro; contamos pares distintos
        // (funcionário, treinamento) para não deixar o número negativo.
        long realizados = realizadoRepository.buscarParesDistintos().size();
        long pendentes = Math.max(0, funcionarios * treinamentos - realizados);

        // LinkedHashMap mantém a ordem em que os itens foram colocados
        Map<String, Long> dados = new LinkedHashMap<>();
        dados.put("episCadastrados", epiRepository.count());
        dados.put("episEmprestados", emprestimoRepository.countByStatus("EMPRESTADO"));
        dados.put("episDevolvidos", emprestimoRepository.countByStatus("DEVOLVIDO"));
        dados.put("caVencidos", epiRepository.countByValidadeCaBefore(LocalDate.now()));
        dados.put("solicitacoesPendentes", emprestimoRepository.countByStatus("SOLICITADO"));
        dados.put("treinamentosPendentes", pendentes);

        // Exercício 1: funcionários cadastrados
        dados.put("funcionariosCadastrados", funcionarioRepository.count());

        // Exercício 2: estoque baixo (2 unidades ou menos)
        dados.put("estoqueBaixo", epiRepository.countByQuantidadeDisponivelLessThanEqual(2));

        return dados;
    }
}
