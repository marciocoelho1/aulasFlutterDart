package com.senac.api_epi.controllers;

import com.senac.api_epi.entities.Funcionario;
import com.senac.api_epi.repositories.FuncionarioRepository;
import com.senac.api_epi.service.AutorizacaoService;
import com.senac.api_epi.service.FuncionarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class FuncionarioController {

    private final FuncionarioRepository repository;
    private final AutorizacaoService autorizacaoService;
    private final FuncionarioService service;

    public FuncionarioController(FuncionarioRepository repository,
                                 AutorizacaoService autorizacaoService,
                                 FuncionarioService service) {
        this.repository = repository;
        this.autorizacaoService = autorizacaoService;
        this.service = service;
    }

    // GET /funcionarios?adminId=1 -> lista de funcionários (apenas ADMIN)
    @GetMapping("/funcionarios")
    public ResponseEntity<?> listar(@RequestParam Long adminId) {
        try {
            autorizacaoService.exigirAdmin(adminId);
            List<Funcionario> funcionarios = repository.findAll();
            return ResponseEntity.ok(funcionarios);
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }

    // POST /funcionarios?adminId=1 -> cadastra um funcionário (apenas ADMIN)
    @PostMapping("/funcionarios")
    public ResponseEntity<?> cadastrar(@RequestBody Funcionario funcionario,
                                       @RequestParam Long adminId) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(service.cadastrar(funcionario, adminId));
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // DELETE /funcionarios/5?adminId=1 -> exclui um funcionário (apenas ADMIN)
    @DeleteMapping("/funcionarios/{id}")
    public ResponseEntity<?> excluir(@PathVariable Long id,
                                     @RequestParam Long adminId) {
        try {
            service.excluir(id, adminId);
            return ResponseEntity.noContent().build();
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
