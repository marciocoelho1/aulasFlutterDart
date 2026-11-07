package com.senac.api_epi.controllers;

import com.senac.api_epi.entities.Emprestimo;
import com.senac.api_epi.service.EmprestimoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/emprestimos")
public class EmprestimoController {

    private final EmprestimoService service;

    public EmprestimoController(EmprestimoService service){
        this.service = service;
    }

    // POST /emprestimos -> funcionário solicita um EPI
    @PostMapping
    public ResponseEntity<?> solicitar(@RequestBody Emprestimo pedido){
        try {
            Emprestimo emprestimo = service.solicitar(pedido);
            return ResponseEntity.status(HttpStatus.CREATED)//201
            .body(emprestimo);
        } catch (IllegalArgumentException e){
            return ResponseEntity.badRequest()//400
            .body(e.getMessage());
        }
    }

    // GET /emprestimos/funcionario/2 -> emprestimos de um funcionário
    @GetMapping("/funcionario/{id}")
    public List<Emprestimo> listarPorFuncionario(@PathVariable Long id){
        return service.listarPorFuncionario(id);
    }
}
