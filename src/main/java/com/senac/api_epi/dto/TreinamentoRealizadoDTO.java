package com.senac.api_epi.dto;

import com.senac.api_epi.entities.TreinamentoRealizado;

import java.time.LocalDate;

/**
 * Saída do GET /treinamentos/realizados/funcionario/{id}.
 *
 * Envia o registro de conclusão + os dados do treinamento e o cálculo de
 * vencimento (data de conclusão + validadeMeses). Fazer o cálculo aqui evita
 * repetir a regra de negócio em cada cliente (app Flutter, web, etc.).
 */
public record TreinamentoRealizadoDTO(
        Long id,
        Long treinamentoId,
        String titulo,
        String descricao,
        String arquivoUrl,
        Integer validadeMeses,
        LocalDate dataConclusao,
        LocalDate dataVencimento,
        boolean vencido,
        boolean podeRefazer,
        long diasParaVencer
) {

    public static TreinamentoRealizadoDTO from(TreinamentoRealizado registro) {
        var treinamento = registro.getTreinamento();
        LocalDate conclusao = registro.getDataConclusao();
        Integer meses = treinamento == null ? null : treinamento.getValidadeMeses();

        // Sem validadeMeses, o treinamento não vence.
        LocalDate vencimento = (meses == null || conclusao == null)
                ? null
                : conclusao.plusMonths(meses);

        boolean vencido = vencimento != null && vencimento.isBefore(LocalDate.now());
        long dias = vencimento == null
                ? Long.MAX_VALUE
                : java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), vencimento);

        return new TreinamentoRealizadoDTO(
                registro.getId(),
                treinamento == null ? null : treinamento.getId(),
                treinamento == null ? null : treinamento.getTitulo(),
                treinamento == null ? null : treinamento.getDescricao(),
                treinamento == null ? null : treinamento.getArquivoUrl(),
                meses,
                conclusao,
                vencimento,
                vencido,
                // Pode refazer quando venceu ou já está no mês de vencimento
                vencido || (vencimento != null && dias <= 30),
                dias
        );
    }
}
