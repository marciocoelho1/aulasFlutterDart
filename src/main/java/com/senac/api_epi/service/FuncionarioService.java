package com.senac.api_epi.service;

import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.EmprestimoRepository;
import com.senac.api_epi.repositories.FuncionarioRepository;
import com.senac.api_epi.repositories.TreinamentoRealizadoRepository;
import org.springframework.stereotype.Service;

@Service
public class FuncionarioService {

    private final FuncionarioRepository funcionarioRepository;
    private final EmprestimoRepository emprestimoRepository;
    private final TreinamentoRealizadoRepository realizadoRepository;
    private final AutorizacaoService autorizacaoService;

    public FuncionarioService(FuncionarioRepository funcionarioRepository,
                              EmprestimoRepository emprestimoRepository,
                              TreinamentoRealizadoRepository realizadoRepository,
                              AutorizacaoService autorizacaoService) {
        this.funcionarioRepository = funcionarioRepository;
        this.emprestimoRepository = emprestimoRepository;
        this.realizadoRepository = realizadoRepository;
        this.autorizacaoService = autorizacaoService;
    }

    // POST /funcionarios?adminId=1 -> cadastra um funcionário
    public Funcionario cadastrar(Funcionario funcionario, Long adminId) {
        autorizacaoService.exigirAdmin(adminId);

        if (funcionario == null) {
            throw new IllegalArgumentException("Informe os dados do funcionário");
        }

        String matricula = texto(funcionario.getMatricula());
        String nome = texto(funcionario.getNome());
        String setor = texto(funcionario.getSetor());
        String senha = texto(funcionario.getSenha());

        if (matricula.isEmpty()) {
            throw new IllegalArgumentException("Informe a matrícula");
        }
        if (matricula.length() > 20) {
            throw new IllegalArgumentException("A matrícula deve ter no máximo 20 caracteres");
        }
        if (nome.isEmpty()) {
            throw new IllegalArgumentException("Informe o nome");
        }
        if (nome.length() > 120) {
            throw new IllegalArgumentException("O nome deve ter no máximo 120 caracteres");
        }
        if (setor.isEmpty()) {
            throw new IllegalArgumentException("Informe o setor");
        }
        if (setor.length() > 80) {
            throw new IllegalArgumentException("O setor deve ter no máximo 80 caracteres");
        }
        if (senha.isEmpty()) {
            throw new IllegalArgumentException("Informe a senha");
        }
        if (senha.length() > 60) {
            throw new IllegalArgumentException("A senha deve ter no máximo 60 caracteres");
        }

        String perfil = texto(funcionario.getPerfil()).toUpperCase();
        if (!perfil.equals("ADMIN") && !perfil.equals("FUNCIONARIO")) {
            throw new IllegalArgumentException("O perfil deve ser ADMIN ou FUNCIONARIO");
        }

        if (funcionarioRepository.findByMatricula(matricula).isPresent()) {
            throw new IllegalArgumentException("Já existe um funcionário com esta matrícula");
        }

        funcionario.setId(null); // sempre um registro novo
        funcionario.setMatricula(matricula);
        funcionario.setNome(nome);
        funcionario.setSetor(setor);
        funcionario.setPerfil(perfil);
        funcionario.setSenha(senha);

        return funcionarioRepository.save(funcionario);
    }

    // DELETE /funcionarios/5?adminId=1 -> exclui um funcionário
    public void excluir(Long id, Long adminId) {
        autorizacaoService.exigirAdmin(adminId);

        if (adminId.equals(id)) {
            throw new IllegalArgumentException("Não é possível excluir o próprio usuário");
        }

        Funcionario funcionario = funcionarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Funcionário não encontrado"));

        // Não apaga histórico: se houver vínculos, a exclusão é bloqueada.
        if (emprestimoRepository.existsByFuncionarioId(id)) {
            throw new IllegalArgumentException(
                    "Funcionário possui empréstimos/solicitações e não pode ser excluído");
        }

        if (realizadoRepository.existsByFuncionarioId(id)) {
            throw new IllegalArgumentException(
                    "Funcionário possui treinamentos concluídos e não pode ser excluído");
        }

        funcionarioRepository.delete(funcionario);
    }

    private String texto(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
