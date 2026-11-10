import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/treinamento.dart';
import '../models/treinamento_realizado.dart';
import 'api_config.dart';

class TreinamentoService {
  // GET /treinamentos
  Future<List<Treinamento>> buscarTreinamentos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/treinamentos'),
    );

    if (response.statusCode == 200) {
      List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista.map((item) => Treinamento.fromJson(item)).toList();
    }

    throw Exception('Erro ao carregar treinamentos');
  }

  // GET /treinamentos/realizados/funcionario/3
  Future<List<TreinamentoRealizado>> buscarRealizados(int funcionarioId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/treinamentos/realizados/funcionario/$funcionarioId',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista
          .map((item) => TreinamentoRealizado.fromJson(item))
          .toList();
    }

    throw Exception(utf8.decode(response.bodyBytes));
  }

  // POST /treinamentos?adminId=1
  Future<Treinamento> cadastrar(
    Treinamento treinamento,
    int adminId,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/treinamentos?adminId=$adminId'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode(treinamento.toJson()),
    );

    final corpo = utf8.decode(response.bodyBytes);

    // 201 = treinamento criado
    if (response.statusCode == 201) {
      return Treinamento.fromJson(json.decode(corpo));
    }

    // 403 = não é admin / 400 = dados inválidos (mensagem vem do backend)
    throw Exception(corpo);
  }

  // POST /treinamentos/2/concluir?funcionarioId=3
  Future<void> concluir(int treinamentoId, int funcionarioId) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/treinamentos/$treinamentoId/concluir'
        '?funcionarioId=$funcionarioId',
      ),
    );

    // 201 = registro de conclusão criado
    if (response.statusCode == 201) {
      return;
    }

    throw Exception(utf8.decode(response.bodyBytes));
  }
}
