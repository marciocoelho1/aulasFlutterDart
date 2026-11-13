import 'package:flutter/material.dart';

import '../models/epi.dart';
import '../models/usuario.dart';
import '../services/api_config.dart';
import '../services/api_erro.dart';
import '../services/epi_service.dart';
import 'epi_detalhe_screen.dart';

/// Filtro aplicado à lista. Usado pelos cards do painel para abrir a
/// listagem já filtrada (CA vencido / estoque baixo).
enum FiltroEpi { todos, caVencido, estoqueBaixo }

class EpiScreen extends StatefulWidget {
  final Usuario usuario;
  final FiltroEpi filtro;

  const EpiScreen({
    super.key,
    required this.usuario,
    this.filtro = FiltroEpi.todos,
  });

  @override
  State<EpiScreen> createState() => _EpiScreenState();
}

class _EpiScreenState extends State<EpiScreen> {
  // O future é criado uma única vez, quando o State é criado, para não
  // refazer a requisição a cada rebuild da tela.
  late final Future<List<Epi>> _futuroEpis = EpiService().buscarEpis();

  String get _titulo {
    switch (widget.filtro) {
      case FiltroEpi.caVencido:
        return 'EPIs com CA vencido';
      case FiltroEpi.estoqueBaixo:
        return 'EPIs com estoque baixo';
      case FiltroEpi.todos:
        return 'Lista de EPIs';
    }
  }

  bool _mostrar(Epi epi) {
    switch (widget.filtro) {
      case FiltroEpi.caVencido:
        return epi.isCaVencido;
      case FiltroEpi.estoqueBaixo:
        return epi.quantidadeDisponivel <= 2;
      case FiltroEpi.todos:
        return true;
    }
  }

  Widget _semImagem(bool vencido) {
    return Container(
      width: 55,
      height: 55,
      color: vencido ? Colors.red.shade100 : Colors.blue.shade50,
      child: Icon(
        Icons.health_and_safety,
        color: vencido ? Colors.red : Colors.blue,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
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
      body: FutureBuilder<List<Epi>>(
        future: _futuroEpis,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${mensagemDeErro(snapshot.error)}'),
            );
          }

          final epis = (snapshot.data ?? []).where(_mostrar).toList();

          if (epis.isEmpty) {
            return Center(
              child: Text(
                widget.filtro == FiltroEpi.todos
                    ? 'Nenhum EPI cadastrado.'
                    : 'Nenhum EPI nesta situação.',
              ),
            );
          }

          return ListView.builder(
            itemCount: epis.length,
            itemBuilder: (context, index) {
              final epi = epis[index];
              final vencido = epi.isCaVencido;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                // Destaca com fundo avermelhado e borda vermelha se o CA estiver vencido
                color: vencido ? Colors.red.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: vencido ? Colors.red : Colors.transparent,
                    width: vencido ? 1.5 : 0,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EpiDetalheScreen(epi: epi, usuario: widget.usuario),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: epi.imagemUrl.isEmpty
                        ? _semImagem(vencido)
                        : Image.network(
                            '${ApiConfig.baseUrl}${epi.imagemUrl}',
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _semImagem(vencido);
                            },
                          ),
                  ),
                  title: Text(
                    epi.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: vencido ? Colors.red.shade900 : Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${epi.categoria} | CA: ${epi.ca}'),
                      // Mostra a quantidade disponível em estoque
                      Text(
                        'Disponível: ${epi.quantidadeDisponivel} un.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      // Exibe aviso em vermelho se o CA estiver vencido
                      if (vencido)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '⚠️ CA VENCIDO (${epi.validadeFormatada})',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
