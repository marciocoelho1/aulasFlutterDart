package com.senac.api_epi.dto;

import com.senac.api_epi.entities.Treinamento;
import com.senac.api_epi.entities.TreinamentoRealizado;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class TreinamentoRealizadoDTOTest {

    private TreinamentoRealizado registro(Integer validadeMeses, LocalDate conclusao) {
        Treinamento treinamento = new Treinamento();
        treinamento.setId(1L);
        treinamento.setTitulo("NR-35");
        treinamento.setValidadeMeses(validadeMeses);

        TreinamentoRealizado registro = new TreinamentoRealizado();
        registro.setId(10L);
        registro.setTreinamento(treinamento);
        registro.setDataConclusao(conclusao);
        return registro;
    }

    @Test
    void semValidadeNaoVenceENaoPermiteRefazer() {
        var dto = TreinamentoRealizadoDTO.from(
                registro(null, LocalDate.now().minusYears(1)));

        assertNull(dto.dataVencimento());
        assertNull(dto.diasParaVencer());
        assertFalse(dto.vencido());
        assertFalse(dto.podeRefazer());
    }

    @Test
    void vencidoPermiteRefazer() {
        var dto = TreinamentoRealizadoDTO.from(
                registro(1, LocalDate.now().minusMonths(2)));

        assertTrue(dto.vencido());
        assertTrue(dto.podeRefazer());
        assertTrue(dto.diasParaVencer() < 0);
    }

    @Test
    void dentroDoPrazoNaoPermiteRefazer() {
        var dto = TreinamentoRealizadoDTO.from(
                registro(12, LocalDate.now().minusMonths(1)));

        assertFalse(dto.vencido());
        assertFalse(dto.podeRefazer());
        assertTrue(dto.diasParaVencer() > 30);
    }

    @Test
    void pertoDeVencerPermiteRefazer() {
        var dto = TreinamentoRealizadoDTO.from(
                registro(1, LocalDate.now().minusDays(10)));

        assertFalse(dto.vencido());
        assertTrue(dto.podeRefazer());
        assertTrue(dto.diasParaVencer() <= 30);
    }
}
