package com.senac.api_epi.repositories;
import com.senac.api_epi.entities.Funcionario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface FuncionarioRepository extends JpaRepository<Funcionario, Long> {
    Optional<Funcionario> findByMatricula(String matricula);
}