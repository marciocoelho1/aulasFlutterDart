import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario.dart';
import 'api_config.dart';

class FuncionarioService {
  Future<List<Funcionario>> buscarFuncionarios() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/funcionarios'));

    if (response.statusCode == 200) {
      final List<dynamic> lista = json.decode(utf8.decode(response.bodyBytes));
      return lista.map((item) => Funcionario.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar funcionários: ${response.statusCode}');
    }
  }
}