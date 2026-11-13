import 'package:flutter/foundation.dart';

class ApiConfig {
  // Permite trocar a URL sem editar código:
  // flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
  static const String _urlDefinida = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;

    // No emulador Android, "localhost" é o próprio emulador.
    // 10.0.2.2 é o endereço da máquina que roda a API.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  // Tempo máximo de espera de cada requisição HTTP.
  static const Duration timeout = Duration(seconds: 10);
}
