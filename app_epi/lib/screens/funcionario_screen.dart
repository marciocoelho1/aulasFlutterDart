import 'package:flutter/material.dart';
import '../models/funcionario.dart';
import '../services/funcionario_service.dart';

class FuncionarioScreen extends StatelessWidget {
  const FuncionarioScreen({super.key});

  // Retorna um ícone específico de acordo com o setor
  IconData _obterIconeSetor(String setor) {
    switch (setor.trim().toLowerCase()) {
      case 'manutenção':
      case 'manutencao':
        return Icons.build;
      case 'produção':
      case 'producao':
        return Icons.factory;
      case 'almoxarifado':
        return Icons.inventory;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Funcionario>>(
        future: FuncionarioService().buscarFuncionarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final funcionarios = snapshot.data ?? [];

          if (funcionarios.isEmpty) {
            return const Center(child: Text('Nenhum funcionário cadastrado.'));
          }

          return ListView.builder(
            itemCount: funcionarios.length,
            itemBuilder: (context, index) {
              final func = funcionarios[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      _obterIconeSetor(func.setor),
                      color: Colors.blue.shade800,
                    ),
                  ),
                  title: Text(
                    func.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Matrícula: ${func.matricula}\nSetor: ${func.setor}',
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