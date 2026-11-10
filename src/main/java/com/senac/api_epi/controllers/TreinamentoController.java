package com.senac.api_epi.controllers;

import com.senac.api_epi.entities.Treinamento;
import com.senac.api_epi.service.TreinamentoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/treinamentos")
public class TreinamentoController {

    private final TreinamentoService service;

    public TreinamentoController(TreinamentoService service){
        this.service = service;
    }

    // GET /treinamentos -> treinamentos disponíveis
    @GetMapping
    public List<Treinamento> listar(){
        return service.listar();
    }

    // GET /treinamentos/5 -> um treinamento
    @GetMapping("/{id}")
    public ResponseEntity<?> buscar(@PathVariable Long id){
        try {
            return ResponseEntity.ok(service.buscar(id));
        } catch (IllegalArgumentException e){
            return ResponseEntity.notFound().build();
        }
    }

    // POST /treinamentos?adminId=1 -> cadastra um treinamento
    @PostMapping
    public ResponseEntity<?> cadastrar(@RequestBody Treinamento treinamento,
                                       @RequestParam Long adminId){
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(service.cadastrar(treinamento, adminId));
        } catch (SecurityException e){
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        } catch (IllegalArgumentException e){
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // POST /treinamentos/2/concluir?funcionarioId=3
    @PostMapping("/{id}/concluir")
    public ResponseEntity<?> concluir(@PathVariable Long id, @RequestParam Long funcionarioId){
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(service.concluir(id, funcionarioId));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // GET /treinamentos/realizados/funcionario/3
    @GetMapping("/realizados/funcionario/{id}")
    public ResponseEntity<?> listarRealizados(@PathVariable Long id){
        try {
            return ResponseEntity.ok(service.listarRealizados(id));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
