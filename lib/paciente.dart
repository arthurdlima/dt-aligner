class Paciente {
  // Documentação:
  //https://flutter.dev/docs/development/data-and-backend/json

  String idPaciente,
      nome,
      sobreNome,
      email,
      rua,
      estado,
      cidade,
      complemento,
      numero,
      foto,
      visualizador3d;

  Paciente(
      {this.idPaciente,
      this.nome,
      this.sobreNome,
      this.email,
      this.rua,
      this.estado,
      this.cidade,
      this.numero,
      this.complemento,
      this.foto,
      this.visualizador3d});

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
        idPaciente: json['id_paciente'] as String,
        nome: json['nome'] as String,
        sobreNome: json['sobrenome'] as String,
        email: json['email'] as String,
        rua: json['rua'] as String,
        numero: json['numero'] as String,
        complemento: json['complemento'] as String,
        estado: json['estado'] as String,
        cidade: json['cidade'] as String,
        foto: json['foto'] as String,
        visualizador3d: json['visualizador3d'] as String);
  }
}
