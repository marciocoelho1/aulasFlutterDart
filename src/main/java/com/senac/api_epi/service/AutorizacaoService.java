package com.senac.api_epi.service;

import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.FuncionarioRepository;
import org.springframework.stereotype.Service;

/**
 * Regra de acesso centralizada.
 *
 * Antes, verificarAdmin() estava copiado em cada Service. Se a regra mudasse
 * (novo perfil "Gestor", troca para enum, permissão por setor...), seria
 * preciso caçar todas as cópias e havia risco de alguma ficar para trás.
 * Agora existe uma única fonte da verdade.
 */
@Service
public class AutorizacaoService {

    public static final String PERFIL_ADMIN = "Admin";

    private final FuncionarioRepository funcionarioRepository;

    public AutorizacaoService(FuncionarioRepository funcionarioRepository) {
        this.funcionarioRepository = funcionarioRepository;
    }

    /**
     * Garante que o usuário informado existe e é administrador.
     *
     * @throws SecurityException se o usuário não existir ou não for admin
     */
    public Funcionario exigirAdmin(Long usuarioId) {
        if (usuarioId == null) {
            throw new SecurityException("Informe o usuário (adminId)");
        }

        Funcionario usuario = funcionarioRepository.findById(usuarioId)
                .orElseThrow(() -> new SecurityException("Usuário não encontrado"));

        String perfil = usuario.getPerfil() == null ? "" : usuario.getPerfil().trim();

        // equalsIgnoreCase + trim: evita quebrar com "admin", "ADMIN" ou "Admin "
        if (!PERFIL_ADMIN.equalsIgnoreCase(perfil)) {
            throw new SecurityException(
                    "Apenas administradores podem realizar esta operação");
        }

        return usuario;
    }

    /** Atalho booleano, para quando não se quer lançar exceção. */
    public boolean isAdmin(Long usuarioId) {
        if (usuarioId == null) {
            return false;
        }
        return funcionarioRepository.findById(usuarioId)
                .map(f -> PERFIL_ADMIN.equalsIgnoreCase(
                        f.getPerfil() == null ? "" : f.getPerfil().trim()))
                .orElse(false);
    }
}
