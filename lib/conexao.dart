import 'dart:convert';
import 'package:http/http.dart' as http; // adicionar pacote no pubspec.yaml
import 'paciente.dart';

class Conexao {
  static const ROOT =
      'https://arthurdlima.com/digital_aligner/controller/controller_pacientes.php';

  static const _ACAO_RETORNAR_TODOS = 'RETORNAR_TODOS';
  static const _ACAO_ADD_PACIENTE = 'ADD_PACIENTE';
  static const _ACAO_ATUALIZAR_PACIENTE = 'ATUALIZAR_PACIENTE';
  static const _ACAO_DEL_PACIENTE = 'DEL_PACIENTE';

  // Retornar pacientes
  static Future<List<Paciente>> retornarPacientes() async {
    try {
      var mapa = Map<String, dynamic>();
      mapa['rota'] = _ACAO_RETORNAR_TODOS;
      final resposta = await http.post(ROOT, body: mapa);
      print('Resposta retornar pacientes: ${resposta.body}');

      if (200 == resposta.statusCode) {
        List<Paciente> lista = parseResposta(resposta.body);
        return lista;
      } else {
        return List<Paciente>();
      }
    } catch (e) {
      return List<Paciente>();
    }
  }

  static List<Paciente> parseResposta(String bodyResposta) {
    final parsed = json.decode(bodyResposta).cast<Map<String, dynamic>>();
    return parsed.map<Paciente>((json) {
      return Paciente.fromJson(json);
    }).toList();
  }

  // Adicionar paciente
  static Future<String> adicionarPaciente(
      String nome,
      String sobrenome,
      String email,
      String rua,
      String numero,
      String complemento,
      String estado,
      String cidade,
      String foto,
      String visualizador3d) async {
    try {
      var mapa = Map<String, dynamic>();
      mapa['rota'] = _ACAO_ADD_PACIENTE;
      mapa['nome'] = nome;
      mapa['sobrenome'] = sobrenome;
      mapa['email'] = email;
      mapa['rua'] = rua;
      mapa['numero'] = numero;
      mapa['complemento'] = complemento;
      mapa['estado'] = estado;
      mapa['cidade'] = cidade;
      mapa['foto'] = foto;
      mapa['visualizador3d'] = visualizador3d;
      final resposta = await http.post(ROOT, body: mapa);

      print('Resposta adicionar paciente: ${resposta.body}');
      if (200 == resposta.statusCode) {
        return resposta.body;
      } else {
        return "Erro!";
      }
    } catch (e) {
      return "Erro!";
    }
  }
  // Atualizar paciente

  static Future<String> atualizarPaciente(
      String idPaciente,
      String nome,
      String sobrenome,
      String email,
      String rua,
      String numero,
      String complemento,
      String estado,
      String cidade,
      String foto,
      String visualizador3d) async {
    try {
      var mapa = Map<String, dynamic>();
      mapa['rota'] = _ACAO_ATUALIZAR_PACIENTE;
      mapa['id_paciente'] = idPaciente;
      mapa['nome'] = nome;
      mapa['sobrenome'] = sobrenome;
      mapa['email'] = email;
      mapa['rua'] = rua;
      mapa['numero'] = numero;
      mapa['complemento'] = complemento;
      mapa['estado'] = estado;
      mapa['cidade'] = cidade;
      mapa['foto'] = foto;
      mapa['visualizador3d'] = visualizador3d;

      final resposta = await http.post(ROOT, body: mapa);
      print('Resposta atualizar paciente: ${resposta.body}');

      if (200 == resposta.statusCode) {
        return resposta.body;
      } else {
        return "Erro!";
      }
    } catch (e) {
      return "Erro!";
    }
  }

  // Deletar paciente

  static Future<String> deletarPaciente(String idPaciente) async {
    try {
      var mapa = Map<String, dynamic>();
      mapa['rota'] = _ACAO_DEL_PACIENTE;
      mapa['id_paciente'] = idPaciente;

      final resposta = await http.post(ROOT, body: mapa);
      print('Resposta atualizar paciente: ${resposta.body}');

      if (200 == resposta.statusCode) {
        return resposta.body;
      } else {
        return "Erro!";
      }
    } catch (e) {
      return "Erro!";
    }
  }
}
