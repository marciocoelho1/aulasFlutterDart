import 'epi.dart';

class Emprestimo {
  final int id;
  final String dataEmprestimo;
  final String status;
  final String observacao;
  final Epi epi;

  Emprestimo({
    required this.id,
    required this.dataEmprestimo,
    required this.status,
    required this.observacao,
    required this.epi,
  });

  // Formata a data de AAAA-MM-DD para DD/MM/AAAA
  String get dataFormatada {
    try {
      final partes = dataEmprestimo.split('-');
      if (partes.length == 3) {
        return '\${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return dataEmprestimo;
    } catch (_) {
      return dataEmprestimo;
    }
  }

  factory Emprestimo.fromJson(Map<String, dynamic> json) {
    return Emprestimo(
      id: json['id'],
      dataEmprestimo: json['dataEmprestimo'] ?? '',
      status: json['status'] ?? '',
      observacao: json['observacao'] ?? '',
      epi: Epi.fromJson(json['epi']),
    );
  }
}