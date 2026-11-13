import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/emprestimo.dart';
import 'api_config.dart';

class EmprestimoService {
  // Envia solicitação de empréstimo para a API
  Future<void> solicitar({
    required int funcionarioId,
    required int epiId,
    required String observacao,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/emprestimos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'funcionario': {'id': funcionarioId},
            'epi': {'id': epiId},
            'observacao': observacao,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 201) {
      return;
    }

    throw Exception(utf8.decode(response.bodyBytes));
  }

  // Busca os empréstimos do funcionário logado
  Future<List<Emprestimo>> buscarPorFuncionario(int id) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/emprestimos/funcionario/$id'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista.map((item) => Emprestimo.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar empréstimos: ${response.statusCode}');
    }
  }

  // Todas as solicitações (tela SolicitacoesScreen)
  Future<List<Emprestimo>> buscarTodos() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/emprestimos'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista.map((item) => Emprestimo.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar solicitações: ${response.statusCode}');
    }
  }

  // PUT /emprestimos/5/aprovar?adminId=1 -> SOLICITADO vira EMPRESTADO
  Future<void> aprovar(int id, int adminId) async {
    final response = await http
        .put(
          Uri.parse(
            '${ApiConfig.baseUrl}/emprestimos/$id/aprovar?adminId=$adminId',
          ),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(utf8.decode(response.bodyBytes));
  }

  // PUT /emprestimos/5/devolver?adminId=1 -> EMPRESTADO vira DEVOLVIDO
  Future<void> devolver(int id, int adminId) async {
    final response = await http
        .put(
          Uri.parse(
            '${ApiConfig.baseUrl}/emprestimos/$id/devolver?adminId=$adminId',
          ),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(utf8.decode(response.bodyBytes));
  }
}
