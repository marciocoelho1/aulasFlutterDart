class Epi {
  final int id;
  final String nome;
  final String categoria;
  final String ca;
  final String validadeCa;
  final String imagemUrl;
  final int quantidadeDisponivel;

  Epi({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.ca,
    required this.validadeCa,
    required this.imagemUrl,
    required this.quantidadeDisponivel,
  });

  // Verifica se a data do CA já expirou em relação à data atual
  bool get isCaVencido {
    try {
      final validade = DateTime.parse(validadeCa);
      return validade.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Alias para compatibilidade com epi_detalhe_screen.dart
  bool get caVencido => isCaVencido;

  // Formata a data de AAAA-MM-DD para DD/MM/AAAA
  String get validadeFormatada {
    try {
      final partes = validadeCa.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return validadeCa;
    } catch (_) {
      return validadeCa;
    }
  }

  factory Epi.fromJson(Map<String, dynamic> json) {
    return Epi(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'],
      ca: json['ca'],
      validadeCa: json['validadeCa'] ?? '',
      imagemUrl: json['imagemUrl'] ?? '',
      quantidadeDisponivel: json['quantidadeDisponivel'] ?? 0,
    );
  }
}
