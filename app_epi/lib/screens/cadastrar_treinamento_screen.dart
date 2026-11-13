import 'package:flutter/material.dart';

import '../models/treinamento.dart';
import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/treinamento_service.dart';

/// Tela exclusiva do administrador: cria um treinamento.
/// Envia POST /treinamentos?adminId={id do usuário logado}.
class CadastrarTreinamentoScreen extends StatefulWidget {
  final Usuario usuario;

  const CadastrarTreinamentoScreen({super.key, required this.usuario});

  @override
  State<CadastrarTreinamentoScreen> createState() =>
      _CadastrarTreinamentoScreenState();
}

class _CadastrarTreinamentoScreenState
    extends State<CadastrarTreinamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final arquivoController = TextEditingController();
  final validadeController = TextEditingController();

  bool salvando = false;

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    arquivoController.dispose();
    validadeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
    });

    // O usuário digita só o nome do arquivo ("nr06.pdf").
    // O backend espera o caminho servido por /arquivos/...
    final nomeArquivo = arquivoController.text.trim();
    String? arquivoUrl;
    if (nomeArquivo.isNotEmpty) {
      arquivoUrl = nomeArquivo.startsWith('/')
          ? nomeArquivo
          : '/arquivos/$nomeArquivo';
    }

    final validadeTexto = validadeController.text.trim();

    final treinamento = Treinamento(
      id: 0, // o backend sempre cria um novo
      titulo: tituloController.text.trim(),
      descricao: descricaoController.text.trim().isEmpty
          ? null
          : descricaoController.text.trim(),
      arquivoUrl: arquivoUrl,
      validadeMeses: validadeTexto.isEmpty ? null : int.parse(validadeTexto),
    );

    try {
      final criado = await TreinamentoService().cadastrar(
        treinamento,
        widget.usuario.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Treinamento cadastrado: ${criado.titulo}'),
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
        title: const Text('Cadastrar Treinamento'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: tituloController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex.: NR-06 – Uso de EPIs',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o título do treinamento';
                }
                if (valor.trim().length > 120) {
                  return 'O título deve ter no máximo 120 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descricaoController,
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: arquivoController,
              decoration: const InputDecoration(
                labelText: 'Nome do arquivo',
                hintText: 'nr06.pdf',
                helperText:
                    'Arquivo já existente em static/arquivos do backend',
                prefixIcon: Icon(Icons.picture_as_pdf),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: validadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Validade (meses)',
                hintText: 'Ex.: 12 para reciclagem anual. Vazio = não vence.',
                prefixIcon: Icon(Icons.event_repeat),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return null; // opcional
                final meses = int.tryParse(texto);
                if (meses == null || meses <= 0) {
                  return 'Informe um número de meses maior que zero';
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
