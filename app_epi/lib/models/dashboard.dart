class Dashboard {
  final int episCadastrados;
  final int episEmprestados;
  final int episDevolvidos;
  final int caVencidos;
  final int solicitacoesPendentes;
  final int treinamentosPendentes;
  final int funcionariosCadastrados;
  final int estoqueBaixo;

  Dashboard({
    required this.episCadastrados,
    required this.episEmprestados,
    required this.episDevolvidos,
    required this.caVencidos,
    required this.solicitacoesPendentes,
    required this.treinamentosPendentes,
    required this.funcionariosCadastrados,
    required this.estoqueBaixo,
  });

  // As chaves são as mesmas do Map montado no DashboardService (Java)
  factory Dashboard.fromJson(Map<String, dynamic> json){
    return Dashboard(
      episCadastrados: json['episCadastrados'],
      episEmprestados: json['episEmprestados'],
      episDevolvidos: json['episDevolvidos'],
      caVencidos: json['caVencidos'],
      solicitacoesPendentes: json['solicitacoesPendentes'],
      treinamentosPendentes: json['treinamentosPendentes'],
      funcionariosCadastrados: json['funcionariosCadastrados'],
      estoqueBaixo: json['estoqueBaixo'],
    );
  }
}