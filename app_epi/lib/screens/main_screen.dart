import 'package:flutter/material.dart';

import 'epi_screen.dart';
import 'funcionario_screen.dart';

import '../models/usuario.dart';
import 'login_screen.dart';

class MainScreen extends StatelessWidget {
  final Usuario usuario;
  const MainScreen({
    super.key,
    required this.usuario,});

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
              accountName: Text(usuario.nome),
              accountEmail: Text(
                usuario.perfil,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  usuario.nome[0],
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            //const DrawerHeader(
              //decoration: BoxDecoration(color: Colors.blue),
              //child: Text(
                //'Menu Principal',
                //style: TextStyle(color: Colors.white, fontSize: 22),
              //),
            //),
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
                  MaterialPageRoute(builder: (context) => const EpiScreen()),
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
                  MaterialPageRoute(builder: (context) => const FuncionarioScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
                );
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Bem-vindo ${usuario.nome}',
          style: const TextStyle(fontSize: 18),
        ),
        //child: Text(
          //'Selecione uma opção no menu lateral',
          //style: TextStyle(fontSize: 18),
        ),
      );
  }
}