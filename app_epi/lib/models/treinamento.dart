class Treinamento {
  final int id;
  final String titulo;
  final String? descricao; // pode vir nulo
  final String? arquivoUrl; // pode vir nulo (treinamento sem material)

  /// Reciclagem periódica (ex.: NR-35).
  /// null = treinamento sem validade (nunca vence).
  final int? validadeMeses;

  Treinamento({
    required this.id,
    required this.titulo,
    this.descricao,
    this.arquivoUrl,
    this.validadeMeses,
  });

  factory Treinamento.fromJson(Map<String, dynamic> json) {
    return Treinamento(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      arquivoUrl: json['arquivoUrl'],
      validadeMeses: json['validadeMeses'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'arquivoUrl': arquivoUrl,
      'validadeMeses': validadeMeses,
    };
  }
}
