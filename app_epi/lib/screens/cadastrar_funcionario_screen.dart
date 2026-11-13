import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/funcionario_service.dart';

/// Tela exclusiva do administrador: cadastra um funcionário.
/// Envia POST /funcionarios?adminId={id do usuário logado}.
class CadastrarFuncionarioScreen extends StatefulWidget {
  final Usuario usuario;

  const CadastrarFuncionarioScreen({super.key, required this.usuario});

  @override
  State<CadastrarFuncionarioScreen> createState() =>
      _CadastrarFuncionarioScreenState();
}

class _CadastrarFuncionarioScreenState
    extends State<CadastrarFuncionarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final matriculaController = TextEditingController();
  final nomeController = TextEditingController();
  final setorController = TextEditingController();
  final senhaController = TextEditingController();

  String perfil = 'FUNCIONARIO';
  bool salvando = false;

  @override
  void dispose() {
    matriculaController.dispose();
    nomeController.dispose();
    setorController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
    });

    try {
      final criado = await FuncionarioService().cadastrar(
        matricula: matriculaController.text.trim(),
        nome: nomeController.text.trim(),
        setor: setorController.text.trim(),
        perfil: perfil,
        senha: senhaController.text,
        adminId: widget.usuario.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Funcionário "${criado.nome}" cadastrado.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemDeErro(e)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar funcionário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: matriculaController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Matrícula *',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Informe a matrícula';
                if (texto.length > 20) {
                  return 'A matrícula deve ter no máximo 20 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nomeController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Informe o nome';
                if (texto.length > 120) {
                  return 'O nome deve ter no máximo 120 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: setorController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Setor *',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Informe o setor';
                if (texto.length > 80) {
                  return 'O setor deve ter no máximo 80 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: perfil,
              decoration: const InputDecoration(
                labelText: 'Perfil *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'FUNCIONARIO',
                  child: Text('FUNCIONARIO'),
                ),
                DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => perfil = valor);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: senhaController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => salvando ? null : salvar(),
              decoration: const InputDecoration(
                labelText: 'Senha *',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor ?? '';
                if (texto.isEmpty) return 'Informe a senha';
                if (texto.length > 60) {
                  return 'A senha deve ter no máximo 60 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(salvando ? 'Salvando...' : 'Cadastrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
