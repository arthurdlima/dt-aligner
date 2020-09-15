import 'dart:ui' as ui;
import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'paciente.dart';
import 'conexao.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

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

  final IFrameElement _iframeElement = IFrameElement();
  Widget _iframeWidget;
  //controladores
  TextEditingController _nomeController,
      _sobreNomeController,
      _emailController,
      _ruaController,
      _numeroController,
      _complementoController,
      _estadoController,
      _cidadeController,
      _visualizador3dController;

  Paciente _pacienteSelecionado;
  bool _estaAtualizando;
  bool _estaAdicionando;

  // Para upload de imagens
  //GlobalKey _formKey = new GlobalKey();
  List<int> _arquivoSelecionado;
  Uint8List _dadosBytes;
  bool _isVisible;

  @override
  void initState() {
    super.initState();
    _pacientes = [];
    _estaAtualizando = false;
    _estaAdicionando = false;

    _iframeElement.height = '500';
    _iframeElement.width = '500';
    _iframeElement.src =
        'https://sketchfab.com/models/1de3ecf4ff3b41648fd0ae982bb2ac9a/embed?autostart=1';
    _iframeElement.style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iframeElement,
    );

    _iframeWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: 'iframeElement',
    );

    _scaffoldKey = GlobalKey(); // Pegar contexto para mostrar o snackbar widget

    _nomeController = TextEditingController();
    _sobreNomeController = TextEditingController();
    _emailController = TextEditingController();
    _ruaController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();
    _estadoController = TextEditingController();
    _cidadeController = TextEditingController();
    _visualizador3dController = TextEditingController();

    //_formKey = new GlobalKey();
    _arquivoSelecionado = List<int>();
    _dadosBytes = new Uint8List(8);
    _isVisible = false;

    _retornarPacientes();
  }

  // Atualizar title no AppBar

  // Para envio de imagens
  Future _enviarImg() async {
    try {
      var url = Uri.parse(
          'https://arthurdlima.com/digital_aligner/controller/controller_pacientes.php');

      var requisicao = new http.MultipartRequest("POST", url)
        ..fields['rota'] = 'UPLOAD_IMAGEM';
      requisicao
        ..files.add(await http.MultipartFile.fromBytes(
            'file', _arquivoSelecionado,
            contentType: new MediaType('application', 'octet-stream'),
            filename: _pacienteSelecionado.idPaciente));
      // resolver isso aqui dps
      requisicao.send().then((resposta) async {
        http.Response.fromStream(resposta).then((response) {
          if (response.statusCode == 200) {
            print(response.body);
          }
        });
      });
    } catch (e) {
      print("Erro ao tentar enviar imagem.");
    }
  }

  // Para upload de imagens
  _escolherImg() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.click();
    // Para conversão de imagens
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      void _handleResult(Object resultado) {
        setState(() {
          _dadosBytes =
              Base64Decoder().convert(resultado.toString().split(",").last);
          _arquivoSelecionado = _dadosBytes;
          _isVisible = true;
          _showSnackBar(context, "Imagem carregada!");
          //Criando novo popup e carregando as antigas variáveis
          _estaAdicionando
              ? _criarFormularioAdd(context)
              : _criarFormulario(context);
        });
      }

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
      // Para retirar o popup e atualizar o seu UI em _handleResult
      Navigator.pop(context);
    });
  }

  // metodo dart _showSnackBar. Variável contexto deve ser context.
  _showSnackBar(context, mensagem) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(mensagem)));
  }

  _retornarPacientes() {
    Conexao.retornarPacientes().then((pacientes) {
      setState(() {
        _pacientes = pacientes;
      });
    });
  }

  _adicionarPaciente() {
    if (_emailController.text.isEmpty) {
      _showSnackBar(context, '*email é obrigatórios!');
      print('*email é obrigatório!');
      return;
    }

    Conexao.adicionarPaciente(
            _nomeController.text,
            _sobreNomeController.text,
            _emailController.text,
            _ruaController.text,
            _numeroController.text,
            _complementoController.text,
            _estadoController.text,
            _cidadeController.text,
            _visualizador3dController.text)
        .then((resultado) {
      print(resultado);
      if ('paciente adicionado com sucesso' == resultado) {
        _retornarPacientes(); // Retorna nova lista após adicionar
        _showSnackBar(context, resultado);
        _clearValues();
      }
    });
  }

  _atualizarPaciente() {
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
            _visualizador3dController.text)
        .then((resultado) {
      print(resultado);
      if ('paciente atualizado com sucesso' == resultado) {
        _retornarPacientes(); // Retorna nova lista após atualização
        setState(() {
          _estaAtualizando = false;
        });
        _showSnackBar(context, resultado);
        _clearValues();
      }
    });
  }

  _deletarPaciente(Paciente paciente) {
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
    _visualizador3dController.text = '';
    //Limpar variavel img
    _arquivoSelecionado = null;
    _dadosBytes = null;
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
    _visualizador3dController.text = paciente.visualizador3d;
  }

  // DataTable com lista de pacientes
  SingleChildScrollView _dataBody() {
    final ScrollController _scrollController = ScrollController();
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.nome), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.sobreNome), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.email), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.rua), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.numero), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.complemento), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.estado), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.cidade), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.foto), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(Text(paciente.visualizador3d), onTap: () {
                      _mostrarValores(paciente);
                      _criarFormulario(context);
                      setState(() {
                        _pacienteSelecionado = paciente;
                        _estaAtualizando = true;
                        _estaAdicionando = false;
                        _isVisible = false;
                      });
                    }),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _pacienteSelecionado = null;
                        });
                        _deletarPaciente(paciente);
                        _isVisible = false;
                      },
                    ))
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  _criarFormulario(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Atualizar Paciente"),
            content: Container(
              width: 800,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ListBody(
                    children: <Widget>[
                      _pacienteSelecionado.foto.isEmpty
                          ? Image.asset(
                              'web/assets/sem-imagem.jpg',
                              height: 200,
                            )
                          : Image.network(
                              _pacienteSelecionado.foto,
                              height: 200,
                              key: ValueKey(new Random().nextInt(100)),
                            ),
                      Text(
                        "Nome",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _nomeController,
                      ),
                      Text(
                        "Sobrenome",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _sobreNomeController,
                      ),
                      Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _emailController,
                      ),
                      Text(
                        "Rua",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _ruaController,
                      ),
                      Text(
                        "Numero",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _numeroController,
                      ),
                      Text(
                        "Complemento",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _complementoController,
                      ),
                      Text(
                        "Estado",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _estadoController,
                      ),
                      Text(
                        "Cidade",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _cidadeController,
                      ),
                      Text(
                        "Foto",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _escolherImg();
                        },
                        child: const Text('Carregar Foto',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Visibility(
                        visible: _isVisible,
                        child: Text('Imagem Carregada!',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        "Visualizador 3D",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _visualizador3dController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('Atualizar'),
                onPressed: () {
                  //Se imagem estiver carregada, enviá-la
                  if (_isVisible == true) {
                    _enviarImg();
                  }
                  _atualizarPaciente();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _criarFormularioAdd(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Adicionar Paciente"),
            content: Container(
              width: 800,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ListBody(
                    children: <Widget>[
                      Image.asset(
                        'web/assets/sem-imagem.jpg',
                        height: 200,
                      ),
                      Text(
                        "Nome",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _nomeController,
                      ),
                      Text(
                        "Sobrenome",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _sobreNomeController,
                      ),
                      Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _emailController,
                      ),
                      Text(
                        "Rua",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _ruaController,
                      ),
                      Text(
                        "Numero",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _numeroController,
                      ),
                      Text(
                        "Complemento",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _complementoController,
                      ),
                      Text(
                        "Estado",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _estadoController,
                      ),
                      Text(
                        "Cidade",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _cidadeController,
                      ),
                      Text(
                        "Foto",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _escolherImg();
                        },
                        child: const Text('Carregar Foto',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Visibility(
                        visible: _isVisible,
                        child: Text('Imagem Carregada!',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        "Visualizador 3D",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _visualizador3dController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('Adicionar'),
                onPressed: () {
                  //Se imagem estiver carregada, enviá-la
                  if (_isVisible == true) {
                    _enviarImg();
                  }
                  _adicionarPaciente();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.indigo[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'web/assets/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
          ],
        ),
        actions: <Widget>[],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Center(
            heightFactor: 2,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: _dataBody(),
                    ),
                    Center(
                      child: SizedBox(
                        height: 400,
                        width: 400,
                        child: _iframeWidget,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _clearValues();
            _estaAdicionando = true;
            _estaAtualizando = false;
          });
          _criarFormularioAdd(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
