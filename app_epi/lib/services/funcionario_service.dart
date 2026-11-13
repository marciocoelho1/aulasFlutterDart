import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/funcionario.dart';
import 'api_config.dart';

class FuncionarioService {
  // GET /funcionarios?adminId=1 -> apenas ADMIN pode listar
  Future<List<Funcionario>> buscarFuncionarios(int adminId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/funcionarios?adminId=$adminId'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista.map((item) => Funcionario.fromJson(item)).toList();
    }

    throw Exception(_mensagem(response));
  }

  // POST /funcionarios?adminId=1 -> apenas ADMIN pode cadastrar
  Future<Funcionario> cadastrar({
    required String matricula,
    required String nome,
    required String setor,
    required String perfil,
    required String senha,
    required int adminId,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/funcionarios?adminId=$adminId'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'matricula': matricula,
            'nome': nome,
            'setor': setor,
            'perfil': perfil,
            'senha': senha,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 201) {
      return Funcionario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    }

    throw Exception(_mensagem(response));
  }

  // DELETE /funcionarios/5?adminId=1 -> apenas ADMIN pode excluir
  Future<void> excluir(int id, int adminId) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/funcionarios/$id?adminId=$adminId'),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    throw Exception(_mensagem(response));
  }

  String _mensagem(http.Response response) {
    final corpo = utf8.decode(response.bodyBytes);
    return corpo.isEmpty
        ? 'Erro ao processar a requisição: ${response.statusCode}'
        : corpo;
  }
}
