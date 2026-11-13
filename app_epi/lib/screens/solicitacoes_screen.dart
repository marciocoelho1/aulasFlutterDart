import 'package:flutter/material.dart';

import '../models/emprestimo.dart';
import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/emprestimo_service.dart';

// Tela do painel: lista todas as solicitações de EPI.
// SOLICITADO  -> Aprovar  (vira EMPRESTADO)
// EMPRESTADO  -> Devolver (vira DEVOLVIDO)
class SolicitacoesScreen extends StatefulWidget {
  final Usuario usuario;

  const SolicitacoesScreen({super.key, required this.usuario});

  @override
  State<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends State<SolicitacoesScreen> {
  late Future<List<Emprestimo>> carregamento;
  int? processandoId;

  @override
  void initState() {
    super.initState();
    carregamento = EmprestimoService().buscarTodos();
  }

  Future<void> recarregar() async {
    final futuro = EmprestimoService().buscarTodos();
    setState(() {
      carregamento = futuro;
    });
    try {
      await futuro;
    } catch (_) {
      // O FutureBuilder abaixo já exibe a mensagem de erro.
    }
  }

  // Mesmas cores usadas em Meus Empréstimos
  Color _obterCorStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SOLICITADO':
        return Colors.orange;
      case 'EMPRESTADO':
        return Colors.green;
      case 'DEVOLVIDO':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _executar(int id, Future<void> Function() acao) async {
    setState(() => processandoId = id);

    try {
      await acao();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operação realizada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagemDeErro(e))));
    } finally {
      if (mounted) setState(() => processandoId = null);
    }

    if (mounted) {
      await recarregar();
    }
  }

  // Botão de acordo com o status: só o que pode ser feito aparece
  Widget _acao(Emprestimo emp, bool processando) {
    if (processando) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (emp.status == 'SOLICITADO') {
      return FilledButton.icon(
        onPressed: () => _executar(
          emp.id,
          () => EmprestimoService().aprovar(emp.id, widget.usuario.id),
        ),
        icon: const Icon(Icons.check),
        label: const Text('Aprovar'),
      );
    }

    if (emp.status == 'EMPRESTADO') {
      return OutlinedButton.icon(
        onPressed: () => _executar(
          emp.id,
          () => EmprestimoService().devolver(emp.id, widget.usuario.id),
        ),
        icon: const Icon(Icons.assignment_return),
        label: const Text('Devolver'),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações de EPIs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: recarregar,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Emprestimo>>(
        future: carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Erro: ${mensagemDeErro(snapshot.error)}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final emprestimos = snapshot.data ?? [];

          if (emprestimos.isEmpty) {
            return const Center(child: Text('Nenhuma solicitação registrada.'));
          }

          return RefreshIndicator(
            onRefresh: recarregar,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: emprestimos.length,
              itemBuilder: (context, index) {
                final emp = emprestimos[index];
                final corStatus = _obterCorStatus(emp.status);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: corStatus.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(Icons.assignment, color: corStatus),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.epi.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (emp.funcionario != null)
                                    Text(
                                      'Funcionário: ${emp.funcionario!.nome}',
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: corStatus,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                emp.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Solicitado em ${emp.dataFormatada}'),
                        if (emp.observacao.isNotEmpty)
                          Text('Motivo: ${emp.observacao}'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _acao(emp, processandoId == emp.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
