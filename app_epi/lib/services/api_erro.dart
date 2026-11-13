import 'dart:async';

import 'package:http/http.dart' as http;

/// Converte exceções de rede em mensagens curtas para o usuário.
///
/// Evita mostrar textos técnicos como "SocketException: Connection refused"
/// ou "TimeoutException after 0:00:10.000000".
String mensagemDeErro(Object? erro) {
  if (erro == null) return 'Ocorreu um erro inesperado.';

  if (erro is TimeoutException) {
    return 'O servidor demorou para responder. Tente novamente.';
  }

  if (erro is http.ClientException) {
    return 'Não foi possível conectar à API. '
        'Verifique se o backend está rodando e o endereço configurado.';
  }

  final texto = erro.toString();

  if (texto.contains('SocketException') ||
      texto.contains('Connection refused') ||
      texto.contains('Failed host lookup')) {
    return 'Não foi possível conectar à API. '
        'Verifique se o backend está rodando e o endereço configurado.';
  }

  return texto.replaceFirst('Exception: ', '');
}
