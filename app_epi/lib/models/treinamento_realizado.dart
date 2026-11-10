/// Registro de conclusão de um treinamento.
///
/// O backend (TreinamentoRealizadoDTO) já envia o treinamento embutido e o
/// cálculo de vencimento, então o app não repete a regra de negócio.
class TreinamentoRealizado {
  final int id;
  final int treinamentoId;
  final String titulo;
  final String? descricao;
  final String? arquivoUrl;
  final int? validadeMeses;
  final DateTime dataConclusao;
  final DateTime? dataVencimento;
  final bool vencido;
  final bool podeRefazer;
  final int? diasParaVencer;

  TreinamentoRealizado({
    required this.id,
    required this.treinamentoId,
    required this.titulo,
    this.descricao,
    this.arquivoUrl,
    this.validadeMeses,
    required this.dataConclusao,
    this.dataVencimento,
    this.vencido = false,
    this.podeRefazer = false,
    this.diasParaVencer,
  });

  /// Aceita tanto o formato novo (DTO do backend) quanto o antigo
  /// (objeto com "treinamento" aninhado), para não quebrar o app.
  factory TreinamentoRealizado.fromJson(Map<String, dynamic> json) {
    // Formato antigo: { id, treinamento: {...}, dataConclusao }
    final Map<String, dynamic>? t = json['treinamento'] is Map
        ? Map<String, dynamic>.from(json['treinamento'])
        : null;

    final dataVenc = json['dataVencimento'] ?? t?['dataVencimento'];

    return TreinamentoRealizado(
      id: json['id'],
      treinamentoId: json['treinamentoId'] ?? t?['id'] ?? 0,
      titulo: json['titulo'] ?? t?['titulo'] ?? '',
      descricao: json['descricao'] ?? t?['descricao'],
      arquivoUrl: json['arquivoUrl'] ?? t?['arquivoUrl'],
      validadeMeses: json['validadeMeses'] ?? t?['validadeMeses'],
      dataConclusao: DateTime.parse(json['dataConclusao']),
      dataVencimento: dataVenc == null ? null : DateTime.parse(dataVenc),
      vencido: json['vencido'] ?? false,
      podeRefazer: json['podeRefazer'] ?? false,
      diasParaVencer: json['diasParaVencer'],
    );
  }

  // 04/11/2026
  String get dataFormatada {
    final dia = dataConclusao.day.toString().padLeft(2, '0');
    final mes = dataConclusao.month.toString().padLeft(2, '0');
    return '$dia/$mes/${dataConclusao.year}';
  }

  String? get vencimentoFormatado {
    if (dataVencimento == null) return null;
    final dia = dataVencimento!.day.toString().padLeft(2, '0');
    final mes = dataVencimento!.month.toString().padLeft(2, '0');
    return '$dia/$mes/${dataVencimento!.year}';
  }

  /// Rótulo pronto para a interface.
  String get situacao {
    if (validadeMeses == null || dataVencimento == null) {
      return 'Concluído em $dataFormatada';
    }
    if (vencido) {
      return 'Vencido – refazer';
    }
    if (diasParaVencer != null && diasParaVencer! >= 0 && diasParaVencer! <= 30) {
      return 'Vence em $vencimentoFormatado';
    }
    return 'Válido até $vencimentoFormatado';
  }
}
