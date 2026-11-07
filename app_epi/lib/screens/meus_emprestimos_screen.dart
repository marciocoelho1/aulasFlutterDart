import 'package:flutter/material.dart';
import '../models/emprestimo.dart';
import '../models/usuario.dart';
import '../services/emprestimo_service.dart';

class MeusEmprestimosScreen extends StatelessWidget {
  final Usuario usuario;

  const MeusEmprestimosScreen({
    super.key,
    required this.usuario,
  });

  // Define a cor de acordo com o status (Exercício 3)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Empréstimos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Emprestimo>>(
        future: EmprestimoService().buscarPorFuncionario(usuario.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final emprestimos = snapshot.data ?? [];

          if (emprestimos.isEmpty) {
            return const Center(
              child: Text('Você ainda não possui solicitações ou empréstimos.'),
            );
          }

          return ListView.builder(
            itemCount: emprestimos.length,
            itemBuilder: (context, index) {
              final emp = emprestimos[index];
              final corStatus = _obterCorStatus(emp.status);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corStatus.withOpacity(0.15),
                    child: Icon(Icons.assignment, color: corStatus),
                  ),
                  title: Text(
                    emp.epi.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Data da solicitação: ${emp.dataFormatada}'),
                      Text('Motivo: ${emp.observacao}'),
                    ],
                  ),
                  trailing: Container(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}