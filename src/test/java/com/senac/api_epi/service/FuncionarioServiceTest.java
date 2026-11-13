package com.senac.api_epi.service;

import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.EmprestimoRepository;
import com.senac.api_epi.repositories.FuncionarioRepository;
import com.senac.api_epi.repositories.TreinamentoRealizadoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FuncionarioServiceTest {

    @Mock
    private FuncionarioRepository funcionarioRepository;
    @Mock
    private EmprestimoRepository emprestimoRepository;
    @Mock
    private TreinamentoRealizadoRepository realizadoRepository;
    @Mock
    private AutorizacaoService autorizacaoService;

    @InjectMocks
    private FuncionarioService service;

    private Funcionario novo(String matricula, String perfil) {
        Funcionario f = new Funcionario();
        f.setMatricula(matricula);
        f.setNome("Fulano de Tal");
        f.setSetor("Produção");
        f.setPerfil(perfil);
        f.setSenha("1234");
        return f;
    }

    @Test
    void cadastraNormalizandoPerfil() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.findByMatricula("2001")).thenReturn(Optional.empty());
        when(funcionarioRepository.save(any(Funcionario.class)))
                .thenAnswer(inv -> inv.getArgument(0));

        Funcionario criado = service.cadastrar(novo(" 2001 ", " funcionario "), 1L);

        assertEquals("2001", criado.getMatricula());
        assertEquals("FUNCIONARIO", criado.getPerfil());
    }

    @Test
    void naoCadastraMatriculaDuplicada() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.findByMatricula("1001"))
                .thenReturn(Optional.of(novo("1001", "ADMIN")));

        assertThrows(IllegalArgumentException.class,
                () -> service.cadastrar(novo("1001", "FUNCIONARIO"), 1L));
        verify(funcionarioRepository, never()).save(any());
    }

    @Test
    void naoCadastraPerfilInvalido() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());

        assertThrows(IllegalArgumentException.class,
                () -> service.cadastrar(novo("2002", "GERENTE"), 1L));
    }

    @Test
    void naoExcluiOProprioUsuario() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());

        assertThrows(IllegalArgumentException.class,
                () -> service.excluir(1L, 1L));
        verify(funcionarioRepository, never()).delete(any());
    }

    @Test
    void naoExcluiFuncionarioComEmprestimos() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.findById(2L))
                .thenReturn(Optional.of(novo("1002", "FUNCIONARIO")));
        when(emprestimoRepository.existsByFuncionarioId(2L)).thenReturn(true);

        assertThrows(IllegalArgumentException.class,
                () -> service.excluir(2L, 1L));
        verify(funcionarioRepository, never()).delete(any());
    }

    @Test
    void naoExcluiFuncionarioComTreinamentos() {
        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.findById(2L))
                .thenReturn(Optional.of(novo("1002", "FUNCIONARIO")));
        when(emprestimoRepository.existsByFuncionarioId(2L)).thenReturn(false);
        when(realizadoRepository.existsByFuncionarioId(2L)).thenReturn(true);

        assertThrows(IllegalArgumentException.class,
                () -> service.excluir(2L, 1L));
        verify(funcionarioRepository, never()).delete(any());
    }

    @Test
    void excluiFuncionarioSemVinculos() {
        Funcionario funcionario = novo("2003", "FUNCIONARIO");
        funcionario.setId(3L);

        when(autorizacaoService.exigirAdmin(1L)).thenReturn(new Funcionario());
        when(funcionarioRepository.findById(3L)).thenReturn(Optional.of(funcionario));
        when(emprestimoRepository.existsByFuncionarioId(3L)).thenReturn(false);
        when(realizadoRepository.existsByFuncionarioId(3L)).thenReturn(false);

        service.excluir(3L, 1L);

        verify(funcionarioRepository).delete(funcionario);
    }
}
