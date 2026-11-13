import 'package:flutter/material.dart';

import '../models/funcionario.dart';
import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/funcionario_service.dart';
import 'cadastrar_funcionario_screen.dart';
import 'treinamentos_do_funcionario_screen.dart';

class FuncionarioScreen extends StatefulWidget {
  final Usuario usuario;

  const FuncionarioScreen({super.key, required this.usuario});

  @override
  State<FuncionarioScreen> createState() => _FuncionarioScreenState();
}

class _FuncionarioScreenState extends State<FuncionarioScreen> {
  late Future<List<Funcionario>> _futuroFuncionarios;

  @override
  void initState() {
    super.initState();
    _futuroFuncionarios = _carregar();
  }

  Future<List<Funcionario>> _carregar() {
    return FuncionarioService().buscarFuncionarios(widget.usuario.id);
  }

  Future<void> _recarregar() async {
    final futuro = _carregar();
    setState(() {
      _futuroFuncionarios = futuro;
    });
    try {
      await futuro;
    } catch (_) {
      // O FutureBuilder abaixo já exibe a mensagem de erro.
    }
  }

  Future<void> _adicionar() async {
    final criado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastrarFuncionarioScreen(usuario: widget.usuario),
      ),
    );

    if (criado == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _excluir(Funcionario func) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmarExclusaoDialog(nome: func.nome),
    );

    if (confirmado != true || !mounted) return;

    try {
      await FuncionarioService().excluir(func.id, widget.usuario.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Funcionário "${func.nome}" excluído.')),
      );
      await _recarregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemDeErro(e)), backgroundColor: Colors.red),
      );
    }
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        icon: const Icon(Icons.person_add),
        label: const Text('Adicionar funcionário'),
      ),
      body: FutureBuilder<List<Funcionario>>(
        future: _futuroFuncionarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${mensagemDeErro(snapshot.error)}'),
            );
          }

          final funcionarios = snapshot.data ?? [];

          if (funcionarios.isEmpty) {
            return const Center(child: Text('Nenhum funcionário cadastrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: funcionarios.length,
            itemBuilder: (context, index) {
              final func = funcionarios[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () {
                    // Item 2: abre os treinamentos concluídos do funcionário
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TreinamentosDoFuncionarioScreen(funcionario: func),
                      ),
                    );
                  },
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Excluir funcionário',
                        onPressed: () => _excluir(func),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
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

/// Diálogo de confirmação: só habilita "Excluir" quando o texto é EXCLUIR.
class _ConfirmarExclusaoDialog extends StatefulWidget {
  final String nome;

  const _ConfirmarExclusaoDialog({required this.nome});

  @override
  State<_ConfirmarExclusaoDialog> createState() =>
      _ConfirmarExclusaoDialogState();
}

class _ConfirmarExclusaoDialogState extends State<_ConfirmarExclusaoDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podeExcluir = _controller.text.trim() == 'EXCLUIR';

    return AlertDialog(
      title: const Text('Excluir funcionário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Digite EXCLUIR para confirmar a exclusão de "${widget.nome}".'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'EXCLUIR',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: podeExcluir ? () => Navigator.pop(context, true) : null,
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
