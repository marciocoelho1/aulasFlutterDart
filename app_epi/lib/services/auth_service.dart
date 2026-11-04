import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'api_config.dart';

class AuthService {
  Future<Usuario> login(
    String matricula,
    String senha,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'matricula': matricula,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Matrícula ou senha inválidos',
    );
  }
}