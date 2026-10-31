class Funcionario {
  final int id;
  final String matricula;
  final String nome;
  final String setor;

  Funcionario({
    required this.id,
    required this.matricula,
    required this.nome,
    required this.setor,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json){
    return Funcionario(
      id: json['id'],
      matricula: json['matricula'],
      nome: json['nome'],
      setor: json['setor'],
      );
  }
}