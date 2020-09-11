import 'dart:html';

import 'package:flutter/material.dart';
import 'paciente.dart';
import 'conexao.dart';

// Data Table Widget
class WidgetPacientes extends StatefulWidget {
  WidgetPacientes() : super();

  final String title = 'Data Table Pacientes';

  @override
  EstadoWidgetPacientes createState() => EstadoWidgetPacientes();
}

class EstadoWidgetPacientes extends State<WidgetPacientes> {
  List<Paciente> _pacientes;
  GlobalKey<ScaffoldState> _scaffoldKey;
  //controladores
  TextEditingController _nomeController,
      _sobreNomeController,
      _emailController,
      _ruaController,
      _numeroController,
      _complementoController,
      _estadoController,
      _cidadeController,
      _fotoController,
      _visualizador3dController;

  Paciente _pacienteSelecionado;
  bool _estaAtualizando;
  String _progressoTitle;

  @override
  void initState() {
    super.initState();
    _pacientes = [];
    _estaAtualizando = false;
    _progressoTitle = widget.title;
    _scaffoldKey = GlobalKey(); // Pegar contexto para mostrar o snackbar widget

    _nomeController = TextEditingController();
    _sobreNomeController = TextEditingController();
    _emailController = TextEditingController();
    _ruaController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();
    _estadoController = TextEditingController();
    _cidadeController = TextEditingController();
    _fotoController = TextEditingController();
    _visualizador3dController = TextEditingController();
    _retornarPacientes();
  }

  // Atualizar title no AppBar
  _mostrarProgresso(String mensagem) {
    setState(() {
      _progressoTitle = mensagem;
    });
  }

  // metodo dart _showSnackBar. Variável contexto deve ser context.
  _showSnackBar(context, mensagem) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(mensagem)));
  }

  _retornarPacientes() {
    _mostrarProgresso('Carregando pacientes');
    Conexao.retornarPacientes().then((pacientes) {
      setState(() {
        _pacientes = pacientes;
      });
      _mostrarProgresso(widget.title);
      print("Tamanho ${pacientes.length}");
    });
  }

  _adicionarPaciente() {
    if (_emailController.text.isEmpty) {
      _showSnackBar(context, '*Id e *email são obrigatórios!');
      print('*email é obrigatório!');
      return;
    }
    _mostrarProgresso('Adicionando paciente...');
    Conexao.adicionarPaciente(
            _nomeController.text,
            _sobreNomeController.text,
            _emailController.text,
            _ruaController.text,
            _numeroController.text,
            _complementoController.text,
            _estadoController.text,
            _cidadeController.text,
            _fotoController.text,
            _visualizador3dController.text)
        .then((resultado) {
      print(resultado);
      if ('paciente adicionado com sucesso' == resultado) {
        _retornarPacientes(); // Retorna nova lista após adicionar
        _showSnackBar(context, resultado);
        _mostrarProgresso('Data Table Pacientes');
        _clearValues();
      }
    });
  }

  _atualizarPaciente() {
    setState(() {
      _estaAtualizando = true;
    });
    _mostrarProgresso('Atualizando cliente...');
    Conexao.atualizarPaciente(
            _pacienteSelecionado.idPaciente,
            _nomeController.text,
            _sobreNomeController.text,
            _emailController.text,
            _ruaController.text,
            _numeroController.text,
            _complementoController.text,
            _estadoController.text,
            _cidadeController.text,
            _fotoController.text,
            _visualizador3dController.text)
        .then((resultado) {
      print(resultado);
      if ('paciente atualizado com sucesso' == resultado) {
        _retornarPacientes(); // Retorna nova lista após atualização
        setState(() {
          _estaAtualizando = false;
        });
        _showSnackBar(context, resultado);
        _mostrarProgresso('Data Table Pacientes');
        _clearValues();
      }
    });
  }

  _deletarPaciente(Paciente paciente) {
    _mostrarProgresso('Deletando paciente...');
    Conexao.deletarPaciente(paciente.idPaciente).then((resultado) {
      if ('paciente deletado com sucesso' == resultado) {
        _retornarPacientes(); // Retorna nova lista após deletar
      }
    });
  }

  // Limpar TextFields
  _clearValues() {
    _nomeController.text = '';
    _sobreNomeController.text = '';
    _emailController.text = '';
    _ruaController.text = '';
    _numeroController.text = '';
    _complementoController.text = '';
    _estadoController.text = '';
    _cidadeController.text = '';
    _fotoController.text = '';
    _visualizador3dController.text = '';
  }

  _mostrarValores(Paciente paciente) {
    _nomeController.text = paciente.nome;
    _sobreNomeController.text = paciente.sobreNome;
    _emailController.text = paciente.email;
    _ruaController.text = paciente.rua;
    _numeroController.text = paciente.numero;
    _complementoController.text = paciente.complemento;
    _estadoController.text = paciente.estado;
    _cidadeController.text = paciente.cidade;
    _fotoController.text = paciente.foto;
    _visualizador3dController.text = paciente.visualizador3d;
  }

  //38:48
  // DataTable com lista de pacientes
  SingleChildScrollView _dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('Id'),
            ),
            DataColumn(
              label: Text('Nome'),
            ),
            DataColumn(
              label: Text('Sobrenome'),
            ),
            DataColumn(
              label: Text('Email'),
            ),
            DataColumn(
              label: Text('Rua'),
            ),
            DataColumn(
              label: Text('Número'),
            ),
            DataColumn(
              label: Text('Complemento'),
            ),
            DataColumn(
              label: Text('Estado'),
            ),
            DataColumn(
              label: Text('Cidade'),
            ),
            DataColumn(
              label: Text('Foto'),
            ),
            DataColumn(
              label: Text('Visualizador 3D'),
            ),
            DataColumn(
              label: Text('DELETAR'),
            ),
          ],
          rows: _pacientes
              .map(
                (paciente) => DataRow(cells: [
                  DataCell(Text(paciente.idPaciente), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.nome), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.sobreNome), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.email), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.rua), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.numero), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.complemento), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.estado), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.cidade), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.foto), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(Text(paciente.visualizador3d), onTap: () {
                    _mostrarValores(paciente);
                    _pacienteSelecionado = paciente;
                    setState(() {
                      _estaAtualizando = true;
                    });
                  }),
                  DataCell(IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deletarPaciente(paciente);
                    },
                  ))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_progressoTitle), // metodo _mostrarProgresso
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _retornarPacientes(),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _nomeController,
                  decoration: InputDecoration.collapsed(hintText: 'Nome'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _sobreNomeController,
                  decoration: InputDecoration.collapsed(hintText: 'Sobrenome'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration.collapsed(hintText: 'Email'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _ruaController,
                  decoration: InputDecoration.collapsed(hintText: 'Rua'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _numeroController,
                  decoration: InputDecoration.collapsed(hintText: 'Número'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _complementoController,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Complemento'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _estadoController,
                  decoration: InputDecoration.collapsed(hintText: 'Estado'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _cidadeController,
                  decoration: InputDecoration.collapsed(hintText: 'Cidade'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _fotoController,
                  decoration: InputDecoration.collapsed(hintText: 'Foto'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _visualizador3dController,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Visualizador 3d'),
                ),
              ),
              //Mostrar botões apenas quando for atualizar paciente
              _estaAtualizando
                  ? Row(
                      children: <Widget>[
                        OutlineButton(
                          child: Text('ATUALIZAR'),
                          onPressed: () {
                            _atualizarPaciente();
                          },
                        ),
                        OutlineButton(
                          child: Text('CANCELAR'),
                          onPressed: () {
                            setState(() {
                              _estaAtualizando = false;
                            });
                            _clearValues();
                          },
                        ),
                      ],
                    )
                  : Container(),
              Container(
                child: _dataBody(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _adicionarPaciente();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
