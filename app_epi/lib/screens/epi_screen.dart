import 'package:flutter/material.dart';
import '../models/epi.dart';
import '../services/epi_service.dart';
import '../services/api_config.dart';

class EpiScreen extends StatelessWidget {
  const EpiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de EPIs'),
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
        future: EpiService().buscarEpis(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final epis = snapshot.data ?? [];

          if (epis.isEmpty) {
            return const Center(
              child: Text('Nenhum EPI cadastrado.'),
            );
          }

          return ListView.builder(
            itemCount: epis.length,
            itemBuilder: (context, index) {
              final epi = epis[index];
              final urlImagem = '${ApiConfig.baseUrl}${epi.imagemUrl}';
              final vencido = epi.isCaVencido;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      urlImagem,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
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
                            '⚠️ CA VENCIDO (${epi.validadeCa})',
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