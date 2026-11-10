package com.senac.api_epi.service;

import com.senac.api_epi.dto.TreinamentoRealizadoDTO;
import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.entities.Treinamento;
import com.senac.api_epi.entities.TreinamentoRealizado;
import com.senac.api_epi.repositories.FuncionarioRepository;
import com.senac.api_epi.repositories.TreinamentoRealizadoRepository;
import com.senac.api_epi.repositories.TreinamentoRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class TreinamentoService {

    private final TreinamentoRepository treinamentoRepository;
    private final TreinamentoRealizadoRepository realizadoRepository;
    private final FuncionarioRepository funcionarioRepository;
    private final AutorizacaoService autorizacao;

    public TreinamentoService(TreinamentoRepository treinamentoRepository,
                              TreinamentoRealizadoRepository realizadoRepository,
                              FuncionarioRepository funcionarioRepository,
                              AutorizacaoService autorizacao) {
        this.treinamentoRepository = treinamentoRepository;
        this.realizadoRepository = realizadoRepository;
        this.funcionarioRepository = funcionarioRepository;
        this.autorizacao = autorizacao;
    }

    public List<Treinamento> listar() {
        return treinamentoRepository.findAllByOrderByTituloAsc();
    }

    public Treinamento buscar(Long id) {
        return treinamentoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Treinamento não encontrado"));
    }

    // Só o administrador cadastra treinamentos
    public Treinamento cadastrar(Treinamento treinamento, Long adminId) {
        // Regra de acesso centralizada em AutorizacaoService
        autorizacao.exigirAdmin(adminId);

        if (treinamento.getTitulo() == null
                || treinamento.getTitulo().isBlank()) {
            throw new IllegalArgumentException("Informe o título do treinamento");
        }

        if (treinamento.getValidadeMeses() != null && treinamento.getValidadeMeses() <= 0) {
            throw new IllegalArgumentException("A validade em meses deve ser maior que zero");
        }

        treinamento.setId(null); // sempre um registro novo
        return treinamentoRepository.save(treinamento);
    }

    // Registra que o funcionário concluiu o treinamento
    public TreinamentoRealizado concluir(Long treinamentoId, Long funcionarioId) {
        Funcionario funcionario = funcionarioRepository.findById(funcionarioId)
                .orElseThrow(() -> new IllegalArgumentException("Funcionário não encontrado"));

        Treinamento treinamento = treinamentoRepository.findById(treinamentoId)
                .orElseThrow(() -> new IllegalArgumentException("Treinamento não encontrado"));

        boolean jaConcluiu = realizadoRepository
                .existsByFuncionarioIdAndTreinamentoId(funcionario.getId(), treinamento.getId());

        // Se já concluiu uma vez, só permite de novo quando o certificado venceu
        if (jaConcluiu) {
            boolean podeRefazer = realizadoRepository
                    .findFirstByFuncionarioIdAndTreinamentoIdOrderByDataConclusaoDesc(
                            funcionario.getId(), treinamento.getId())
                    .map(registro -> TreinamentoRealizadoDTO.from(registro).podeRefazer())
                    .orElse(false);

            if (!podeRefazer) {
                throw new IllegalArgumentException("Este treinamento já foi concluído");
            }
        }

        TreinamentoRealizado registro = new TreinamentoRealizado();
        registro.setFuncionario(funcionario);
        registro.setTreinamento(treinamento);
        registro.setDataConclusao(LocalDate.now());

        return realizadoRepository.save(registro);
    }

    // GET /treinamentos/realizados/funcionario/{id}
    public List<TreinamentoRealizadoDTO> listarRealizados(Long funcionarioId) {
        if (!funcionarioRepository.existsById(funcionarioId)) {
            throw new IllegalArgumentException("Funcionário não encontrado");
        }

        return realizadoRepository
                .findByFuncionarioIdOrderByDataConclusaoDesc(funcionarioId)
                .stream()
                .map(TreinamentoRealizadoDTO::from)
                .toList();
    }
}
