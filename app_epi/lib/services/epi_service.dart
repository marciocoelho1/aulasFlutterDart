import 'dart:convert'; // Trabalha com JSON
import 'package:http/http.dart' as http; // Faz requisições HTTP

import '../models/epi.dart';
import 'api_config.dart';

class EpiService {
  // Busca a lista de EPIs na API
  Future<List<Epi>> buscarEpis() async {
    // Faz uma requisição GET para o endpoint /epis
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/epis'));

    // Verifica se a requisição foi bem-sucedida
    if (response.statusCode == 200) {
      // Converte o JSON recebido em uma lista Dart
      final List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));

      // Transforma cada item da lista em um objeto Epi
      return lista.map((item) => Epi.fromJson(item)).toList();
    } else {
      // Lança uma exceção em caso de erro
      throw Exception('Erro ao carregar EPIs: ${response.statusCode}');
    }
  }
}