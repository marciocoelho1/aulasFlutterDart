import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/treinamento.dart';
import '../models/treinamento_realizado.dart';
import '../models/usuario.dart';
import '../services/api_config.dart';
import '../services/treinamento_service.dart';

class TreinamentosScreen extends StatefulWidget {
  final Usuario usuario;

  const TreinamentosScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<TreinamentosScreen> createState() => _TreinamentosScreenState();
}

class _TreinamentosScreenState extends State<TreinamentosScreen> {
  late Future<void> carregamento;
  List<Treinamento> treinamentos = [];

  // id do treinamento -> registro de conclusão
  Map<int, TreinamentoRealizado> concluidos = {};

  int? processandoId;

  @override
  void initState() {
    super.initState();
    carregamento = carregarDados();
  }

  // Busca as duas listas e cruza as informações
  Future<void> carregarDados() async {
    final service = TreinamentoService();
    treinamentos = await service.buscarTreinamentos();
    final realizados =
        await service.buscarRealizados(widget.usuario.id);

    concluidos = {};
    for (final r in realizados) {
      // Se o mesmo treinamento foi refeito, fica o registro mais recente
      concluidos[r.treinamentoId] = r;
    }
  }

  void recarregar() {
    setState(() {
      carregamento = carregarDados();
    });
  }

  // Abre o PDF do treinamento no navegador / leitor do celular
  Future<void> abrirMaterial(Treinamento t) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${t.arquivoUrl}');
    final abriu =
        await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o material')),
      );
    }
  }

  Future<void> marcarConcluido(Treinamento t) async {
    // Item 3: confirmação antes de registrar a conclusão
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir treinamento'),
        content: Text(
          'Confirma que você leu o material e concluiu o treinamento?\n\n'
          '${t.titulo}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sim, concluí'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    setState(() {
      processandoId = t.id;
    });

    try {
      await TreinamentoService().concluir(t.id, widget.usuario.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Treinamento concluído: ${t.titulo}'),
          backgroundColor: Colors.green,
        ),
      );
      recarregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processandoId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamentos de Segurança'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (treinamentos.isEmpty) {
            return const Center(
              child: Text('Nenhum treinamento disponível'),
            );
          }

          final total = treinamentos.length;
          final feitos = concluidos.length;

          return Column(
            children: [
              // Resumo do progresso
              Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$feitos de $total treinamentos concluídos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: feitos / total,
                        minHeight: 8,
                        color: Colors.green,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de treinamentos
              Expanded(
                child: ListView.builder(
                  itemCount: treinamentos.length,
                  itemBuilder: (context, index) {
                    final t = treinamentos[index];
                    final registro = concluidos[t.id];
                    final concluido = registro != null;
                    final vencido = registro?.vencido ?? false;
                    final podeRefazer = registro?.podeRefazer ?? false;

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
                                Icon(
                                  vencido
                                      ? Icons.error
                                      : (concluido
                                          ? Icons.check_circle
                                          : Icons.school),
                                  color: vencido
                                      ? Colors.red
                                      : (concluido
                                          ? Colors.green
                                          : Colors.blue),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(t.descricao ?? ''),
                            if (t.validadeMeses != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Reciclagem a cada ${t.validadeMeses} meses',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            // Wrap quebra a linha se não couber na tela
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (t.arquivoUrl != null)
                                  OutlinedButton.icon(
                                    onPressed: () => abrirMaterial(t),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('Material'),
                                  ),
                                if (registro != null && !vencido && !podeRefazer)
                                  Chip(
                                    avatar: const Icon(Icons.check,
                                        color: Colors.green),
                                    label: Text(
                                      'Concluído em ${registro.dataFormatada}',
                                    ),
                                    backgroundColor: Colors.green.shade50,
                                  )
                                else if (registro != null && vencido)
                                  Chip(
                                    avatar: const Icon(Icons.error,
                                        color: Colors.red),
                                    label: const Text('Vencido – refazer'),
                                    backgroundColor: Colors.red.shade50,
                                    labelStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (registro != null)
                                  Chip(
                                    avatar: const Icon(Icons.hourglass_bottom,
                                        color: Colors.orange),
                                    label: Text(registro.situacao),
                                    backgroundColor: Colors.orange.shade50,
                                  ),
                                if (registro == null || podeRefazer)
                                  ElevatedButton.icon(
                                    onPressed: processandoId == null
                                        ? () => marcarConcluido(t)
                                        : null,
                                    icon: const Icon(Icons.task_alt),
                                    label: Text(
                                      registro == null
                                          ? 'Marcar como Concluído'
                                          : 'Refazer treinamento',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
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