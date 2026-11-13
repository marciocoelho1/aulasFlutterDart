import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool carregando = false;

  Future<void> fazerLogin() async {
    if (carregando) return;

    try {
      setState(() {
        carregando = true;
      });
      Usuario usuario = await AuthService().login(
        matriculaController.text,
        senhaController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(usuario: usuario)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagemDeErro(e))));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: matriculaController,
              textInputAction: TextInputAction.done,
              // Enter na matrícula também aciona o botão "Entrar".
              onSubmitted: (_) => fazerLogin(),
              decoration: const InputDecoration(
                labelText: 'Matrícula',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: senhaController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              // Enter no campo de senha aciona o botão "Entrar".
              onSubmitted: (_) => fazerLogin(),
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : fazerLogin,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
