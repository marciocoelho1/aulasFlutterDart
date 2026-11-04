class Usuario {
  final int id;
  final String matricula;
  final String nome;
  final String setor;
  final String perfil;
  Usuario({
    required this.id,
    required this.matricula,
    required this.nome,
    required this.setor,
    required this.perfil,
  });
  factory Usuario.fromJson(
    Map<String, dynamic> json){
      return Usuario(id: json['id'],
      matricula: json['matricula'],
      nome: json['nome'],
      setor: json['setor'],
      perfil: json['perfil'],
      );
    }
}