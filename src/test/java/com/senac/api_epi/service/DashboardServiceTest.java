package com.senac.api_epi.service;

import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.EpiRepository;
import com.senac.api_epi.repositories.EmprestimoRepository;
import com.senac.api_epi.repositories.FuncionarioRepository;
import com.senac.api_epi.repositories.TreinamentoRealizadoRepository;
import com.senac.api_epi.repositories.TreinamentoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private EpiRepository epiRepository;
    @Mock
    private EmprestimoRepository emprestimoRepository;
    @Mock
    private FuncionarioRepository funcionarioRepository;
    @Mock
    private TreinamentoRepository treinamentoRepository;
    @Mock
    private TreinamentoRealizadoRepository realizadoRepository;
    @Mock
    private AutorizacaoService autorizacaoService;

    @InjectMocks
    private DashboardService service;

    @Test
    void calculaPendentesComParesDistintos() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.count()).thenReturn(3L);
        when(treinamentoRepository.count()).thenReturn(4L);
        when(realizadoRepository.buscarParesDistintos()).thenReturn(List.of(
                new Object[] {2L, 3L},
                new Object[] {1L, 2L}));

        Map<String, Long> dados = service.indicadores(1L);

        // 3 funcionários x 4 treinamentos - 2 pares concluídos = 10
        assertEquals(10L, dados.get("treinamentosPendentes"));
    }

    @Test
    void pendentesNuncaFicamNegativos() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.count()).thenReturn(3L);
        when(treinamentoRepository.count()).thenReturn(4L);
        // Simula mais conclusões do que a matriz funcionário x treinamento.
        when(realizadoRepository.buscarParesDistintos())
                .thenReturn(Collections.nCopies(13, new Object[] {1L, 1L}));

        Map<String, Long> dados = service.indicadores(1L);

        assertEquals(0L, dados.get("treinamentosPendentes"));
    }
}
