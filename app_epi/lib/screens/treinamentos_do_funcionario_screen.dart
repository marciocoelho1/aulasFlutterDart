import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/funcionario.dart';
import '../models/treinamento_realizado.dart';
import '../services/api_config.dart';
import '../services/treinamento_service.dart';

/// Item 2: ao tocar em um funcionário, mostra o histórico de treinamentos.
/// Consome GET /treinamentos/realizados/funcionario/{id}.
class TreinamentosDoFuncionarioScreen extends StatefulWidget {
  final Funcionario funcionario;

  const TreinamentosDoFuncionarioScreen({
    super.key,
    required this.funcionario,
  });

  @override
  State<TreinamentosDoFuncionarioScreen> createState() =>
      _TreinamentosDoFuncionarioScreenState();
}

class _TreinamentosDoFuncionarioScreenState
    extends State<TreinamentosDoFuncionarioScreen> {
  late Future<List<TreinamentoRealizado>> carregamento;

  @override
  void initState() {
    super.initState();
    carregamento =
        TreinamentoService().buscarRealizados(widget.funcionario.id);
  }

  Future<void> abrirMaterial(String? arquivoUrl) async {
    if (arquivoUrl == null || arquivoUrl.isEmpty) return;

    final url = Uri.parse('${ApiConfig.baseUrl}$arquivoUrl');
    final abriu = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o material')),
      );
    }
  }

  // Vermelho = vencido, laranja = perto de vencer, verde = em dia
  Color _cor(TreinamentoRealizado r) {
    if (r.vencido) return Colors.red;
    if (r.diasParaVencer != null &&
        r.diasParaVencer! >= 0 &&
        r.diasParaVencer! <= 30) {
      return Colors.orange;
    }
    return Colors.green;
  }

  // Versão escura da cor, para o texto do Chip ficar legível
  Color _corTexto(TreinamentoRealizado r) {
    if (r.vencido) return Colors.red.shade700;
    if (r.diasParaVencer != null &&
        r.diasParaVencer! >= 0 &&
        r.diasParaVencer! <= 30) {
      return Colors.orange.shade800;
    }
    return Colors.green.shade700;
  }

  IconData _icone(TreinamentoRealizado r) {
    if (r.vencido) return Icons.error;
    if (r.diasParaVencer != null &&
        r.diasParaVencer! >= 0 &&
        r.diasParaVencer! <= 30) {
      return Icons.warning_amber;
    }
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final func = widget.funcionario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamentos concluídos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TreinamentoRealizado>>(
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
                  'Erro: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final realizados = snapshot.data ?? [];

          return Column(
            children: [
              // Cabeçalho com os dados do funcionário
              Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue.shade800),
                  ),
                  title: Text(
                    func.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Matrícula: ${func.matricula}\nSetor: ${func.setor}',
                  ),
                ),
              ),

              if (realizados.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Este funcionário ainda não concluiu nenhum treinamento.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: realizados.length,
                    itemBuilder: (context, index) {
                      final r = realizados[index];
                      final cor = _cor(r);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_icone(r), color: cor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      r.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Concluído em ${r.dataFormatada}'),
                              if (r.validadeMeses != null)
                                Text(
                                  'Validade: ${r.validadeMeses} meses',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(
                                    avatar: Icon(_icone(r), color: cor, size: 18),
                                    label: Text(r.situacao),
                                    backgroundColor: cor.withValues(alpha: 0.12),
                                    labelStyle: TextStyle(
                                      color: _corTexto(r),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (r.arquivoUrl != null)
                                    OutlinedButton.icon(
                                      onPressed: () => abrirMaterial(r.arquivoUrl),
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: const Text('Material'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
