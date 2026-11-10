import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'cadastrar_treinamento_screen.dart';
import 'epi_screen.dart';
import 'funcionario_screen.dart';
import 'login_screen.dart';
import 'meus_emprestimos_screen.dart';
import 'treinamentos_screen.dart';

class MainScreen extends StatelessWidget {
  final Usuario usuario;

  const MainScreen({super.key, required this.usuario});

  // Aula 5: só o administrador enxerga as ações de gestão.
  // trim + toLowerCase evita quebrar com "admin", "ADMIN" ou "Admin ".
  bool get _isAdmin => usuario.perfil.trim().toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empréstimos de EPIs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(usuario.nome),
              accountEmail: Text(usuario.perfil),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40.0, color: Colors.blue),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text('EPIs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpiScreen(usuario: usuario),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Meus Empréstimos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeusEmprestimosScreen(usuario: usuario),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Funcionários'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FuncionarioScreen(),
                  ),
                );
              },
            ),
            //  Aula 6: treinamentos (todos os perfis)
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Treinamentos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TreinamentosScreen(usuario: usuario),
                  ),
                );
              },
            ),
            // Aula 7: item exclusivo do administrador
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.library_add),
                title: const Text('Cadastrar Treinamento'),
                onTap: () {
                  Navigator.pop(context); // fecha o drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CadastrarTreinamentoScreen(usuario: usuario),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Bem-vindo, ${usuario.nome}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
