import 'dart:convert';

import 'package:app_diario_obra/screens/add_atividade_screen.dart';
import 'package:app_diario_obra/screens/select_equipamentos_screen.dart';
import 'package:app_diario_obra/screens/select_mao_de_obra_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/obra/data/models/obra_model.dart';
import '../features/relatorio/data/models/relatorio_model.dart';
import '../features/relatorio/domain/entities/relatorio.dart';

class EditRelatorioScreen extends StatefulWidget {
  final RelatorioModel relatorio;
  final ObraModel obra; // Recebe a obra obrigatoriamente (não nullable)

  const EditRelatorioScreen(
      {Key? key, required this.relatorio, required this.obra})
      : super(key: key);

  @override
  _EditRelatorioScreenState createState() => _EditRelatorioScreenState();
}

class _EditRelatorioScreenState extends State<EditRelatorioScreen> {
  late DateTime _selectedDate;
  String? _diaSemana; // Dia da semana, calculado a partir da data
  bool _manhaSelected = true; // Seleção para Manhã (conforme a imagem)
  bool _tardeSelected = true; // Seleção para Tarde (conforme a imagem)
  bool _noiteSelected = true; // Seleção para Noite (conforme a imagem)
  String? _weatherManhaTempo = 'Nublado'; // Tempo para manhã
  String? _weatherManhaCondicao =
      'Impraticável'; // Condição para manhã (conforme a imagem)
  String? _weatherTardeTempo =
      'Chuvoso'; // Tempo para tarde (conforme a imagem)
  String? _weatherTardeCondicao =
      'Praticável'; // Condição para tarde (conforme a imagem)
  String? _weatherNoiteTempo = 'Claro'; // Tempo para noite (conforme a imagem)
  String? _weatherNoiteCondicao =
      'Praticável'; // Condição para noite (conforme a imagem)
  double? _indicePluviometrico; // Índice pluviométrico em mm
  List<Map<String, dynamic>> _maoDeObraItems =
      []; // Lista de itens de mão de obra
  List<Map<String, dynamic>> _equipamentosItems =
      []; // Lista de itens de equipamentos
  List<Map<String, dynamic>> _atividadesItems =
      []; // Lista de itens de atividades
  List<Map<String, dynamic>> _ocorrenciasItems =
      []; // Lista de itens de ocorrências
  List<Map<String, dynamic>> _comentariosItems =
      []; // Lista de itens de comentários
  List<Map<String, dynamic>> _fotosItems = []; // Lista de itens de fotos
  List<Map<String, dynamic>> _videosItems = []; // Lista de itens de vídeos
  List<Map<String, dynamic>> _anexosItems = []; // Lista de itens de anexos
  bool _preenchendoRelatorio =
      true; // Estado inicial para "Preenchendo Relatório"
  bool _revisarRelatorio = false; // Estado inicial para "Revisar Relatório"
  bool _aprovado = false; // Estado inicial para "Aprovado"
  int?
      _prazoContratual; // Prazo contratual (dias entre dataInicio e previsaoTermino)
  int?
      _prazoDecorrido; // Prazo decorrido (1 se dataInicio é hoje, aumenta com o tempo, 0 se dataInicio ainda não chegou)
  int? _prazoVencer; // Prazo a vencer (prazoContratual - prazoDecorrido)

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRelatorioData(); // Recarrega os dados ao voltar para a tela
  }

  @override
  void initState() {
    super.initState();
    _loadRelatorioData();
  }

  Future<void> _loadRelatorioData() async {
    final relatorioDoc = await _firestore
        .collection('obras')
        .doc(widget.relatorio.obraId)
        .collection('relatorios')
        .doc(widget.relatorio.id)
        .get();

    if (relatorioDoc.exists) {
      final relatorioData = relatorioDoc.data() as Map<String, dynamic>;
      final relatorio = RelatorioModel.fromMap(relatorioData, relatorioDoc.id);

      setState(() {
        _selectedDate = relatorio.data;
        _diaSemana = _getDayOfWeek(_selectedDate);

        final content = relatorio.content;
        final condicaoClimatica =
            content['Condição climática'] as List<dynamic>? ?? [];

        if (condicaoClimatica.isNotEmpty &&
            condicaoClimatica[0] is Map<String, dynamic>) {
          final clima = condicaoClimatica[0] as Map<String, dynamic>;
          _manhaSelected = clima['Manhã']?['selecionado'] as bool? ?? false;
          _tardeSelected = clima['Tarde']?['selecionado'] as bool? ?? false;
          _noiteSelected = clima['Noite']?['selecionado'] as bool? ?? false;

          _weatherManhaTempo = clima['Manhã']?['tempo'] as String? ?? 'Nublado';
          _weatherManhaCondicao =
              clima['Manhã']?['condicao'] as String? ?? 'Impraticável';
          _weatherTardeTempo = clima['Tarde']?['tempo'] as String? ?? 'Chuvoso';
          _weatherTardeCondicao =
              clima['Tarde']?['condicao'] as String? ?? 'Praticável';
          _weatherNoiteTempo = clima['Noite']?['tempo'] as String? ?? 'Claro';
          _weatherNoiteCondicao =
              clima['Noite']?['condicao'] as String? ?? 'Praticável';
        }

        final indicePluviometrico =
            content['Índice pluviométrico'] as List<dynamic>? ?? [];
        if (indicePluviometrico.isNotEmpty &&
            indicePluviometrico[0] is Map<String, dynamic>) {
          final quantidade =
              indicePluviometrico[0]['quantidade'] as String? ?? '0';
          _indicePluviometrico =
              double.tryParse(quantidade.replaceAll(',', '.')) ?? 0.0;
        } else {
          _indicePluviometrico = 0.0;
        }

        // Inicializa os itens de mão de obra a partir do Firestore
        _maoDeObraItems =
            (content['Mão de obra'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'quantidade': (item['quantidade'] as num?)?.toInt() ?? 1,
                  };
                }).toList() ??
                [
                  {'title': 'Ajudante', 'quantidade': 1},
                  {'title': 'Mão de Obra Própria', 'quantidade': 1},
                ];

        _equipamentosItems =
            (content['Equipamentos'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'quantidade': (item['quantidade'] as num?)?.toInt() ?? 1,
                  };
                }).toList() ??
                [
                  {'title': 'Escavadeira', 'quantidade': 1},
                ];

        _atividadesItems =
            (content['Atividades'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'descricao': item['descricao'] as String? ?? '',
                    'progresso': (item['progresso'] as num?)?.toDouble() ?? 0.0,
                    'status': item['status'] as String? ?? 'Em andamento',
                    'membros': (item['membros'] as List<dynamic>?)
                            ?.map((m) => {
                                  'title': m['title'] as String? ?? '',
                                  'quantidade':
                                      (m['quantidade'] as num?)?.toInt() ?? 1,
                                })
                            .toList() ??
                        [
                          {'title': 'Ajudante', 'quantidade': 1},
                        ],
                    'foto': item['foto'] as String? ?? '',
                  };
                }).toList() ??
                [
                  {
                    'title': 'Massa',
                    'descricao': '20 M² 10% Em andamento',
                    'progresso': 10.0,
                    'status': 'Em andamento',
                    'membros': [
                      {'title': 'Ajudante', 'quantidade': 1}
                    ],
                    'foto': '',
                  },
                ];

        _ocorrenciasItems =
            (content['Ocorrências'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'descricao': item['descricao'] as String? ?? '',
                    'duracao': item['duracao'] as String? ?? '2h',
                    'impacto': item['impacto'] as String? ?? ':=1',
                    'condicao': item['condicao'] as String? ?? 'Dia Chuvoso',
                    'membros': (item['membros'] as List<dynamic>?)
                            ?.map((m) => {
                                  'title': m['title'] as String? ?? '',
                                  'quantidade':
                                      (m['quantidade'] as num?)?.toInt() ?? 1,
                                })
                            .toList() ??
                        [
                          {'title': 'Ajudante', 'quantidade': 1},
                        ],
                    'foto': item['foto'] as String? ?? '',
                  };
                }).toList() ??
                [
                  {
                    'title': 'Tentou',
                    'descricao': '',
                    'duracao': '2h',
                    'impacto': ':=1',
                    'condicao': 'Dia Chuvoso',
                    'membros': [
                      {'title': 'Ajudante', 'quantidade': 1}
                    ],
                    'foto': '',
                  },
                ];

        _comentariosItems =
            (content['Comentários'] as List<dynamic>?)?.map((item) {
                  return {
                    'autor': item['autor'] as String? ?? '',
                    'data': item['data'] as String? ?? '',
                    'comentario': item['comentario'] as String? ?? '',
                  };
                }).toList() ??
                [
                  {
                    'autor': 'Lucas',
                    'data': '19/02/2025 23:21',
                    'comentario': 'Choveu',
                  },
                ];

        _fotosItems = (content['Fotos'] as List<dynamic>?)?.map((item) {
              return {
                'url': item['url'] as String? ?? '',
                'thumbnail': item['thumbnail'] as String? ?? '',
              };
            }).toList() ??
            [
              {
                'url': '',
                'thumbnail': 'https://via.placeholder.com/100',
              },
              {
                'url': '',
                'thumbnail': 'https://via.placeholder.com/100',
              },
            ];

        _videosItems = (content['Vídeos'] as List<dynamic>?)?.map((item) {
              return {
                'url': item['url'] as String? ?? '',
                'thumbnail': item['thumbnail'] as String? ?? '',
                'duracao': item['duracao'] as String? ?? '00:00',
              };
            }).toList() ??
            [
              {
                'url': '',
                'thumbnail': 'https://via.placeholder.com/100',
                'duracao': '00:00',
              },
            ];

        _anexosItems = (content['Anexos'] as List<dynamic>?)?.map((item) {
              return {
                'nome': item['nome'] as String? ?? '',
                'url': item['url'] as String? ?? '',
              };
            }).toList() ??
            [
              {
                'nome': 'cbcf9efe-b735-49ab-b654-b345b22d5a6a.jpg',
                'url': '',
              },
            ];

        // Calcula os prazos da obra
        final obraComPrazos = ObraModel.calcularPrazos(widget.obra);
        _prazoContratual = obraComPrazos.prazoContratual ?? 0;
        _prazoDecorrido = obraComPrazos.prazoDecorrido ?? 0;
        _prazoVencer = obraComPrazos.prazoVencer ?? 0;

        final status = content['Status'] as List<dynamic>? ?? [];
        if (status.isNotEmpty && status[0] is Map<String, dynamic>) {
          final statusData = status[0] as Map<String, dynamic>;
          _preenchendoRelatorio = statusData['preenchendo'] as bool? ?? false;
          _revisarRelatorio = statusData['revisar'] as bool? ?? false;
          _aprovado = statusData['aprovado'] as bool? ?? false;
        } else {
          _preenchendoRelatorio = true;
          _revisarRelatorio = false;
          _aprovado = false;
        }
      });
    }
  }

  // Método para salvar o relatório atualizado no Firestore
  void _saveRelatorio() async {
    final updatedContent =
        Map<String, List<dynamic>>.from(widget.relatorio.content);

    // Garantir que todas as seções padrão estejam presentes no content
    const allSections =
        Relatorio.allSections; // Usar a constante estática do modelo Relatorio
    for (String section in allSections) {
      if (!updatedContent.containsKey(section)) {
        updatedContent[section] =
            []; // Inicializa como lista vazia se não existir
      }
    }

    // Condição climática
    Map<String, dynamic> condicaoClimatica = {};
    if (_manhaSelected) {
      condicaoClimatica['Manhã'] = {
        'tempo': _weatherManhaTempo,
        'condicao': _weatherManhaCondicao,
        'selecionado': _manhaSelected,
      };
    }
    if (_tardeSelected) {
      condicaoClimatica['Tarde'] = {
        'tempo': _weatherTardeTempo,
        'condicao': _weatherTardeCondicao,
        'selecionado': _tardeSelected,
      };
    }
    if (_noiteSelected) {
      condicaoClimatica['Noite'] = {
        'tempo': _weatherNoiteTempo,
        'condicao': _weatherNoiteCondicao,
        'selecionado': _noiteSelected,
      };
    }
    updatedContent['Condição climática'] = [
      condicaoClimatica.isNotEmpty ? condicaoClimatica : {}
    ];

    // Índice pluviométrico
    updatedContent['Índice pluviométrico'] = [
      {'quantidade': _indicePluviometrico?.toStringAsFixed(2) ?? '0'}
    ];

    // Mão de obra
    updatedContent['Mão de obra'] = _maoDeObraItems
        .map((item) => {
              'title': item['title'],
              'quantidade': item['quantidade'],
            })
        .toList();

    // Equipamentos
    updatedContent['Equipamentos'] = _equipamentosItems
        .map((item) => {
              'title': item['title'],
              'quantidade': item['quantidade'],
            })
        .toList();

    // Atividades
    updatedContent['Atividades'] = _atividadesItems
        .map((item) => {
              'title': item['title'],
              'descricao': item['descricao'],
              'progresso': item['progresso'],
              'status': item['status'],
              'membros': item['membros'],
              'foto': item['foto'],
            })
        .toList();

    // Ocorrências
    updatedContent['Ocorrências'] = _ocorrenciasItems
        .map((item) => {
              'title': item['title'],
              'descricao': item['descricao'],
              'duracao': item['duracao'],
              'impacto': item['impacto'],
              'condicao': item['condicao'],
              'membros': item['membros'],
              'foto': item['foto'],
            })
        .toList();

    // Comentários
    updatedContent['Comentários'] = _comentariosItems
        .map((item) => {
              'autor': item['autor'],
              'data': item['data'],
              'comentario': item['comentario'],
            })
        .toList();

    // Fotos
    updatedContent['Fotos'] = _fotosItems
        .map((item) => {
              'url': item['url'],
              'thumbnail': item['thumbnail'],
            })
        .toList();

    // Vídeos
    updatedContent['Vídeos'] = _videosItems
        .map((item) => {
              'url': item['url'],
              'thumbnail': item['thumbnail'],
              'duracao': item['duracao'],
            })
        .toList();

    // Anexos
    updatedContent['Anexos'] = _anexosItems
        .map((item) => {
              'nome': item['nome'],
              'url': item['url'],
            })
        .toList();

    // Assinatura e status
    String newStatus = 'Preenchendo';
    if (_aprovado) {
      newStatus = 'Aprovado';
    } else if (_revisarRelatorio) {
      newStatus = 'Revisando';
    } else if (_preenchendoRelatorio) {
      newStatus = 'Preenchendo';
    }

    updatedContent['Status'] = [
      {
        'preenchendo': _preenchendoRelatorio,
        'revisar': _revisarRelatorio,
        'aprovado': _aprovado,
      }
    ];

    final updatedRelatorio = widget.relatorio.copyWith(
      data: _selectedDate,
      content: updatedContent,
      status: newStatus,
      sections:
          allSections, // Garante que todas as seções padrão estejam presentes
    );

    try {
      await _firestore
          .collection('obras')
          .doc(widget.relatorio.obraId)
          .collection('relatorios')
          .doc(widget.relatorio.id)
          .set(updatedRelatorio.toMap(), SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Relatório atualizado com sucesso')),
      );
      context.go('/obra_detail/relatorios',
          extra: widget.obra); // Volta para a lista de relatórios
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar relatório: $error')),
      );
    }
  }

  // Método para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _diaSemana = _getDayOfWeek(_selectedDate);
      });
    }
  }

  // Método auxiliar para obter o dia da semana
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Segunda-Feira';
      case 2:
        return 'Terça-Feira';
      case 3:
        return 'Quarta-Feira';
      case 4:
        return 'Quinta-Feira';
      case 5:
        return 'Sexta-Feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Não informado';
    }
  }

  // Método para adicionar um novo item de mão de obra
  void _addMaoDeObraItem() async {
    final selectedItems = await showDialog<List<String>>(
      context: context,
      builder: (context) => SelectMaoDeObraScreen(
        selectedItems:
            _maoDeObraItems.map((item) => item['title'] as String).toList(),
        relatorioId: widget.relatorio.id ?? '',
        obraId: widget.relatorio.obraId,
      ),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      await _refreshMaoDeObraFromFirestore(); // Recarrega os dados do Firestore
    }
  }

  Future<void> _refreshMaoDeObraFromFirestore() async {
    try {
      final relatorioSnapshot = await FirebaseFirestore.instance
          .collection('obras')
          .doc(widget.relatorio.obraId)
          .collection('relatorios')
          .doc(widget.relatorio.id)
          .get();

      if (relatorioSnapshot.exists) {
        final relatorioData = relatorioSnapshot.data() as Map<String, dynamic>;
        final content = relatorioData['content'] as Map<String, dynamic>? ?? {};
        final maoDeObra =
            (content['Mão de obra'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'quantidade': (item['quantidade'] as num?)?.toInt() ?? 1,
                  };
                }).toList() ??
                [];

        setState(() {
          _maoDeObraItems = maoDeObra;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recarregar mão de obra: $error')),
      );
    }
  }

  void _addEquipamentoItem() async {
    final selectedItems = await showDialog<List<String>>(
      context: context,
      builder: (context) => SelectEquipamentosScreen(
        selectedItems:
            _equipamentosItems.map((item) => item['title'] as String).toList(),
        relatorioId: widget.relatorio.id ?? '',
        obraId: widget.relatorio.obraId,
      ),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      await _refreshEquipamentosFromFirestore(); // Recarrega os dados do Firestore
    }
  }

  Future<void> _refreshEquipamentosFromFirestore() async {
    try {
      final relatorioSnapshot = await FirebaseFirestore.instance
          .collection('obras')
          .doc(widget.relatorio.obraId)
          .collection('relatorios')
          .doc(widget.relatorio.id)
          .get();

      if (relatorioSnapshot.exists) {
        final relatorioData = relatorioSnapshot.data() as Map<String, dynamic>;
        final content = relatorioData['content'] as Map<String, dynamic>? ?? {};
        final equipamentos =
            (content['Equipamentos'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'quantidade': (item['quantidade'] as num?)?.toInt() ?? 1,
                  };
                }).toList() ??
                [];

        setState(() {
          _equipamentosItems = equipamentos;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recarregar equipamentos: $error')),
      );
    }
  }

  void _addAtividadeItem() async {
    final updatedAtividade = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAtividadeScreen(
          relatorioId: widget.relatorio.id ?? '',
          obraId: widget.relatorio.obraId,
        ),
      ),
    );

    if (updatedAtividade != null) {
      await _refreshAtividadesFromFirestore(); // Recarrega os dados do Firestore
    }
  }

  Future<void> _refreshAtividadesFromFirestore() async {
    try {
      final relatorioSnapshot = await FirebaseFirestore.instance
          .collection('obras')
          .doc(widget.relatorio.obraId)
          .collection('relatorios')
          .doc(widget.relatorio.id)
          .get();

      if (relatorioSnapshot.exists) {
        final relatorioData = relatorioSnapshot.data() as Map<String, dynamic>;
        final content = relatorioData['content'] as Map<String, dynamic>? ?? {};
        final atividades =
            (content['Atividades'] as List<dynamic>?)?.map((item) {
                  return {
                    'title': item['title'] as String? ?? '',
                    'descricao': item['descricao'] as String? ?? '',
                    'progresso': (item['progresso'] as num?)?.toDouble() ?? 0.0,
                    'status': item['status'] as String? ?? 'Em andamento',
                    'membros': (item['membros'] as List<dynamic>?)
                            ?.map((m) => {
                                  'title': m['title'] as String? ?? '',
                                  'quantidade':
                                      (m['quantidade'] as num?)?.toInt() ?? 1,
                                })
                            .toList() ??
                        [
                          {'title': 'Ajudante', 'quantidade': 1},
                        ],
                    'foto':
                        item['foto'] as String? ?? '', // Caminho ou URL da foto
                  };
                }).toList() ??
                [];

        setState(() {
          _atividadesItems = atividades;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recarregar atividades: $error')),
      );
    }
  }

  void _addOcorrenciaItem() {
    setState(() {
      _ocorrenciasItems.add({
        'title': 'Nova Ocorrência',
        'descricao': '',
        'duracao': '0h',
        'impacto': ':=0',
        'condicao': 'Normal',
        'membros': [
          {'title': 'Ajudante', 'quantidade': 1}
        ],
        'foto': '',
      });
    });
  }

  void _addComentarioItem() {
    setState(() {
      _comentariosItems.add({
        'autor': '',
        'data': DateTime.now()
            .toString()
            .substring(0, 16)
            .replaceAll('T', ' '), // Formato "dd/MM/yyyy HH:mm"
        'comentario': '',
      });
    });
  }

  void _addFotoItem() {
    setState(() {
      _fotosItems.add({
        'url': '',
        'thumbnail': 'https://via.placeholder.com/100', // Thumbnail padrão
      });
    });
  }

  void _addVideoItem() {
    setState(() {
      _videosItems.add({
        'url': '',
        'thumbnail': 'https://via.placeholder.com/100', // Thumbnail padrão
        'duracao': '00:00',
      });
    });
  }

  void _addAnexoItem() {
    setState(() {
      _anexosItems.add({
        'nome': 'novo_anexo.jpg',
        'url': '',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Editar relatório',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/obra_detail/relatorios', extra: widget.obra);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveRelatorio,
            child: Text(
              'Salvar',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('obras')
              .doc(widget.relatorio.obraId)
              .get(),
          builder: (context, obraSnapshot) {
            if (obraSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (obraSnapshot.hasError || !obraSnapshot.hasData) {
              return Center(child: Text('Erro ao carregar dados da obra'));
            }

            final obra = ObraModel.fromMap(
                obraSnapshot.data!.data() as Map<String, dynamic>,
                obraSnapshot.data!.id);

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título "Detalhes do relatório" e botão "Preenchendo Relatório"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalhes do relatório',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            // Lógica para preencher o relatório (atualiza status, se necessário)
                            // Aqui você pode adicionar mais lógica, como abrir um formulário
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('Preenchendo Relatório'),
                        ),
                      ),
                    ],
                  ),
                  Divider(),

                  // Título "Relatório Diário de Obra (RDO)"
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Relatório Diário de Obra (RDO)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Divider(),

                  // Detalhes do relatório
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: _buildEditRow('Data',
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            onTap: () => _selectDate(context)),
                      ),
                    ],
                  ),

                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          'Dia da semana',
                          _diaSemana ?? 'Não informado',
                        ),
                      ),
                      Expanded(
                        child: _buildDetailRow(
                          'Nº do contrato',
                          obra.numeroContrato ?? 'Não informado',
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          'Responsável',
                          obra.responsavel ?? 'Não informado',
                        ),
                      ),
                      Expanded(
                        child: _buildDetailRow(
                          'Contratante',
                          obra.contratante ?? 'Não informado',
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  _buildDetailRow(
                    'Obra',
                    obra.nome ?? 'Não informado',
                  ),
                  Divider(),
                  _buildDetailRow(
                    'Endereço',
                    obra.endereco ?? 'Não informado',
                  ),
                  Divider(),
                  // Prazos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildEditRow(
                            'Prazo contratual',
                            _prazoContratual != null
                                ? '$_prazoContratual dias'
                                : '0 dias',
                            readOnly: true,
                            fontTitleSize: 12),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildEditRow(
                            'Prazo decorrido',
                            _prazoDecorrido != null
                                ? '$_prazoDecorrido dias'
                                : '0 dias',
                            readOnly: true,
                            fontTitleSize: 12),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildEditRow(
                            'Prazo a vencer',
                            _prazoVencer != null
                                ? '$_prazoVencer dias'
                                : '0 dias',
                            readOnly: true,
                            fontTitleSize: 12),
                      ),
                    ],
                  ),
                  Divider(),

                  // Condição climática
                  Text(
                    'Condição climática',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção "Tempo"
                      Text('Tempo',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Divider(),
                      _buildWeatherRow(
                          'Manhã', _manhaSelected, _weatherManhaTempo!),
                      Divider(),
                      _buildWeatherRow(
                          'Tarde', _tardeSelected, _weatherTardeTempo!),
                      Divider(),
                      _buildWeatherRow(
                          'Noite', _noiteSelected, _weatherNoiteTempo!),
                      Divider(),
                      // Seção "Condição"
                      Text('Condição',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Divider(),
                      _buildWeatherRow(
                          'Manhã', _manhaSelected, _weatherManhaCondicao!,
                          isCondition: true),
                      Divider(),
                      _buildWeatherRow(
                          'Tarde', _tardeSelected, _weatherTardeCondicao!,
                          isCondition: true),
                      Divider(),
                      _buildWeatherRow(
                          'Noite', _noiteSelected, _weatherNoiteCondicao!,
                          isCondition: true),
                      Divider(),
                      // Índice pluviométrico
                      Text('Índice pluviométrico',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Divider(),
                      Row(
                        children: [
                          Expanded(child: Text('Quantidade em "mm"')),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue:
                                  _indicePluviometrico?.toStringAsFixed(2) ??
                                      '',
                              decoration: InputDecoration(
                                hintText: 'Ex.: 5,30',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              onChanged: (value) {
                                setState(() {
                                  _indicePluviometrico = double.tryParse(
                                          value.replaceAll(',', '.')) ??
                                      0.0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      // Mão de obra
                      _buildSection(
                          'Mão de obra', _maoDeObraItems, _addMaoDeObraItem),
                      Divider(),

                      // Equipamentos
                      _buildSection('Equipamentos', _equipamentosItems,
                          _addEquipamentoItem),
                      Divider(),

                      // Atividades
                      _buildSectionWithDetails(
                          'Atividades', _atividadesItems, _addAtividadeItem),
                      Divider(),

                      // Ocorrências
                      _buildSectionWithDetails(
                          'Ocorrências', _ocorrenciasItems, _addOcorrenciaItem),
                      Divider(),
                      // Comentários
                      _buildSectionWithComments(
                          'Comentários', _comentariosItems, _addComentarioItem),
                      Divider(),

                      // Fotos
                      _buildSectionWithMedia('Fotos', _fotosItems, _addFotoItem,
                          isVideo: false),
                      Divider(),

                      // Vídeos
                      _buildSectionWithMedia(
                          'Vídeos', _videosItems, _addVideoItem,
                          isVideo: true),
                      Divider(),

                      // Anexos
                      _buildSectionWithAttachments(
                          'Anexos', _anexosItems, _addAnexoItem),
                      Divider(),
                      // Status relatorio
                      Text(
                        'Status Relatório',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _preenchendoRelatorio,
                            onChanged: (value) {
                              setState(() {
                                _preenchendoRelatorio = value ?? false;
                                if (value == true) {
                                  _revisarRelatorio = false;
                                  _aprovado = false;
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text('Preenchendo Relatório'),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Checkbox(
                            value: _revisarRelatorio,
                            onChanged: (value) {
                              setState(() {
                                _revisarRelatorio = value ?? false;
                                if (value == true) {
                                  _preenchendoRelatorio = false;
                                  _aprovado = false;
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text('Revisar Relatório'),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Checkbox(
                            value: _aprovado,
                            onChanged: (value) {
                              setState(() {
                                _aprovado = value ?? false;
                                if (value == true) {
                                  _preenchendoRelatorio = false;
                                  _revisarRelatorio = false;
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          Text('Aprovado'),
                        ],
                      ),
                      // Mão de obra
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Mão de obra (${_maoDeObraItems.length})',
                      //       style: TextStyle(
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.orange,
                      //       ),
                      //     ),
                      //     ElevatedButton(
                      //       onPressed: _addMaoDeObraItem,
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.blue,
                      //         foregroundColor: Colors.white,
                      //         padding: EdgeInsets.symmetric(
                      //             horizontal: 12, vertical: 8),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(5),
                      //         ),
                      //       ),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           Icon(Icons.add, size: 16),
                      //           SizedBox(width: 8),
                      //           Text('Adicionar'),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 8),
                      // ..._maoDeObraItems.map((item) {
                      //   return Row(
                      //     children: [
                      //       Expanded(
                      //         flex: 2,
                      //         child: TextFormField(
                      //           initialValue: item['title'] as String?,
                      //           decoration: InputDecoration(
                      //             labelText: 'Título',
                      //             border: OutlineInputBorder(),
                      //             contentPadding: EdgeInsets.symmetric(
                      //                 vertical: 8, horizontal: 12),
                      //           ),
                      //           onChanged: (value) {
                      //             setState(() {
                      //               item['title'] = value;
                      //             });
                      //           },
                      //         ),
                      //       ),
                      //       SizedBox(width: 8),
                      //       Expanded(
                      //         child: TextFormField(
                      //           initialValue:
                      //               (item['quantidade'] as int?)?.toString(),
                      //           decoration: InputDecoration(
                      //             labelText: 'Quantidade',
                      //             border: OutlineInputBorder(),
                      //             contentPadding: EdgeInsets.symmetric(
                      //                 vertical: 8, horizontal: 12),
                      //           ),
                      //           keyboardType: TextInputType.number,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               item['quantidade'] =
                      //                   int.tryParse(value) ?? 1;
                      //             });
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   );
                      // }).toList(),
                      // Divider(),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  // Widget genérico para seções com itens simples (Mão de obra, Equipamentos)
  Widget _buildSection(
      String title, List<Map<String, dynamic>> items, VoidCallback addItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Adicionar'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) {
          return Column(
            children: [
              ListTile(
                style: ListTileStyle.list,
                title: GestureDetector(
                  onTap: () {
                    // Exibe um diálogo quando o título é clicado
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Excluir Item"),
                          content:
                              Text("Tem certeza que deseja excluir este item?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fecha o diálogo
                              },
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Lógica para excluir o item
                                setState(() {
                                  items.remove(item); // Remove o item da lista
                                });
                                Navigator.of(context).pop(); // Fecha o diálogo
                              },
                              child: Text(
                                "Excluir",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(item['title'] as String? ?? ''),
                ),
                trailing: SizedBox(
                  width: 100, // Define a largura do TextFormField
                  child: TextFormField(
                    initialValue: item['quantidade']
                        .toString(), // Valor inicial da quantidade
                    keyboardType: TextInputType.number, // Teclado numérico
                    textAlign: TextAlign.center, // Alinhamento centralizado
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8), // Ajusta o padding interno
                      border:
                          OutlineInputBorder(), // Borda ao redor do TextFormField
                      isDense: true, // Reduz o espaço interno do campo
                    ),
                    onChanged: (value) {
                      // Atualiza a quantidade do item quando o valor é alterado
                      item['quantidade'] = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ),
              Divider(), // Adiciona uma linha entre os itens
            ],
          );
        }).toList(),
      ],
    );
  }

  // Widget para seções com detalhes adicionais (Atividades, Ocorrências)
  Widget _buildSectionWithDetails(
      String title, List<Map<String, dynamic>> items, VoidCallback addItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Adicionar'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: item['title'] as String?,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    item['title'] = value;
                  });
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: item['descricao'] as String?,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    item['descricao'] = value;
                  });
                },
              ),
              if (title == 'Atividades') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['progresso']?.toString(),
                        decoration: InputDecoration(
                          labelText: 'Progresso (%)',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            item['progresso'] = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['status'] as String?,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            item['status'] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildMemberSection(
                    'Membros', item['membros'] as List<Map<String, dynamic>>),
              ],
              if (title == 'Ocorrências') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['duracao'] as String?,
                        decoration: InputDecoration(
                          labelText: 'Duração',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            item['duracao'] = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['impacto'] as String?,
                        decoration: InputDecoration(
                          labelText: 'Impacto',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            item['impacto'] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: item['condicao'] as String?,
                  decoration: InputDecoration(
                    labelText: 'Condição',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      item['condicao'] = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                _buildMemberSection(
                    'Membros', item['membros'] as List<Map<String, dynamic>>),
              ],
              if (item['foto'] != null && item['foto'].isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    item['foto'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 100);
                    },
                  ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Widget para criar seção de membros (Ajudante)
  Widget _buildMemberSection(String label, List<Map<String, dynamic>> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 8),
        ...members.map((member) {
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: member['title'] as String?,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      member['title'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: (member['quantidade'] as int?)?.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      member['quantidade'] = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Widget para criar as linhas de informação
  Widget _buildDetailRow(String label, String value,
      {bool isStatus = false,
      bool isBold = true,
      double fontSizeTitle = 16,
      double fontSizeSubTitle = 14}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSizeSubTitle,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para criar linhas de detalhes editáveis
  Widget _buildEditRow(String label, String value,
      {bool readOnly = false, VoidCallback? onTap, double fontTitleSize = 16}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontTitleSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Widget para criar linhas de condições climáticas
  Widget _buildWeatherRow(String period, bool isSelected, String value,
      {bool isCondition = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (period == 'Manhã') _manhaSelected = value ?? false;
                    if (period == 'Tarde') _tardeSelected = value ?? false;
                    if (period == 'Noite') _noiteSelected = value ?? false;
                  });
                },
                activeColor: Colors.blue,
              ),
              Text(period),
            ],
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            items: isCondition
                ? ['Praticável', 'Impraticável']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList()
                : ['Nublado', 'Chuvoso', 'Claro']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
            onChanged: isSelected
                ? (newValue) {
                    setState(() {
                      if (period == 'Manhã' && !isCondition)
                        _weatherManhaTempo = newValue;
                      if (period == 'Manhã' && isCondition)
                        _weatherManhaCondicao = newValue;
                      if (period == 'Tarde' && !isCondition)
                        _weatherTardeTempo = newValue;
                      if (period == 'Tarde' && isCondition)
                        _weatherTardeCondicao = newValue;
                      if (period == 'Noite' && !isCondition)
                        _weatherNoiteTempo = newValue;
                      if (period == 'Noite' && isCondition)
                        _weatherNoiteCondicao = newValue;
                    });
                  }
                : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            disabledHint: Text(value),
          ),
        ),
      ],
    );
  }

  // Widget para seções de comentários
  Widget _buildSectionWithComments(
      String title, List<Map<String, dynamic>> items, VoidCallback addItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Adicionar'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: item['autor'] as String?,
                decoration: InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    item['autor'] = value;
                  });
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: item['data'] as String?,
                decoration: InputDecoration(
                  labelText: 'Data (dd/MM/yyyy HH:mm)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    item['data'] = value;
                  });
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: item['comentario'] as String?,
                decoration: InputDecoration(
                  labelText: 'Comentário',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    item['comentario'] = value;
                  });
                },
              ),
              SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Widget para seções de mídia (Fotos, Vídeos)
  Widget _buildSectionWithMedia(
      String title, List<Map<String, dynamic>> items, VoidCallback addItem,
      {required bool isVideo}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Adicionar'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        item['thumbnail'] as String,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported, size: 100);
                        },
                      ),
                      if (isVideo)
                        Center(
                          child: Icon(Icons.play_arrow,
                              color: Colors.white, size: 40),
                        ),
                      if (isVideo)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Text(
                            item['duracao'] as String,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                backgroundColor: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['url'] as String?,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        item['url'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Widget para seções de anexos
  Widget _buildSectionWithAttachments(
      String title, List<Map<String, dynamic>> items, VoidCallback addItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Adicionar'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['nome'] as String?,
                    decoration: InputDecoration(
                      labelText: 'Nome do Arquivo',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        item['nome'] = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['url'] as String?,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        item['url'] = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.download, color: Colors.blue),
                  onPressed: () {
                    // Lógica para download do anexo (implemente conforme necessário)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Download de ${item['nome']} iniciado')),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
