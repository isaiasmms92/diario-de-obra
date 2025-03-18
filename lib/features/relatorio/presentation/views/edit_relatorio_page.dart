import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../screens/add_atividade_screen.dart';
import '../../../../screens/select_equipamentos_screen.dart';
import '../../../../screens/select_mao_de_obra_screen.dart';
import '../../domain/entities/relatorio.dart';
import '../controllers/relatorio_editor_controller.dart';

class EditRelatorioPage extends StatefulWidget {
  final String relatorioId;
  final String obraId;

  const EditRelatorioPage({
    super.key,
    required this.relatorioId,
    required this.obraId,
  });

  @override
  _EditRelatorioPageState createState() => _EditRelatorioPageState();
}

class _EditRelatorioPageState extends State<EditRelatorioPage> {
  late EditRelatorioController _controller;
  DateTime _selectedDate = DateTime.now();
  String? _diaSemana;
  bool _manhaSelected = true;
  bool _tardeSelected = true;
  bool _noiteSelected = true;
  String? _weatherManhaTempo = 'Nublado';
  String? _weatherManhaCondicao = 'Impraticável';
  String? _weatherTardeTempo = 'Chuvoso';
  String? _weatherTardeCondicao = 'Praticável';
  String? _weatherNoiteTempo = 'Claro';
  String? _weatherNoiteCondicao = 'Praticável';
  double? _indicePluviometrico = 0.0;
  List<Map<String, dynamic>> _maoDeObraItems = [];
  List<Map<String, dynamic>> _equipamentosItems = [];
  List<Map<String, dynamic>> _atividadesItems = [];
  List<Map<String, dynamic>> _ocorrenciasItems = [];
  List<Map<String, dynamic>> _comentariosItems = [];
  List<Map<String, dynamic>> _fotosItems = [];
  List<Map<String, dynamic>> _videosItems = [];
  List<Map<String, dynamic>> _anexosItems = [];
  bool _preenchendoRelatorio = true;
  bool _revisarRelatorio = false;
  bool _aprovado = false;
  int? _prazoContratual;
  int? _prazoDecorrido;
  int? _prazoVencer;

  @override
  void initState() {
    super.initState();
    _controller = context.read<EditRelatorioController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega os dados ao voltar para a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await _controller.loadData(widget.obraId, widget.relatorioId);

    if (_controller.relatorio != null) {
      _updateStateFromRelatorio(_controller.relatorio!);
    }
  }

  // Atualiza o estado local a partir do relatório carregado
  void _updateStateFromRelatorio(Relatorio relatorio) {
    setState(() {
      _selectedDate = relatorio.data;
      _diaSemana = _getDayOfWeek(_selectedDate);

      final content = relatorio.content;
      final condicaoClimatica =
          content['Condição Climática'] as List<dynamic>? ?? [];

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

      _maoDeObraItems = (content['Mão de obra'] as List<dynamic>?)?.map((item) {
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

      _atividadesItems = (content['Atividades'] as List<dynamic>?)?.map((item) {
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

      if (_controller.obra != null) {
        final obraComPrazos = _controller.obra!;
        _prazoContratual = obraComPrazos.prazoContratual ?? 0;
        _prazoDecorrido = obraComPrazos.prazoDecorrido ?? 0;
        _prazoVencer = obraComPrazos.prazoVencer ?? 0;
      }

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

  // Método para criar um relatório atualizado
  Relatorio _buildUpdatedRelatorio() {
    final allSections = Relatorio.allSections;

    final updatedContent =
        Map<String, List<dynamic>>.from(_controller.relatorio!.content);

    // Garantir que todas as seções padrão estejam presentes no content
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
    updatedContent['Condição Climática'] = [
      condicaoClimatica.isNotEmpty ? condicaoClimatica : {}
    ];

    // Índice pluviométrico
    updatedContent['Indice Pluviométrico'] = [
      {'quantidade': _indicePluviometrico?.toStringAsFixed(2) ?? '0'}
    ];

    // Mão de obra
    updatedContent['Mão de Obra'] = _maoDeObraItems
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
    updatedContent['Videos'] = _videosItems
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

    // Status
    String newStatus = 'Preenchendo';
    if (_aprovado) {
      newStatus = 'Aprovado';
    } else if (_revisarRelatorio) {
      newStatus = 'Revisando';
    }

    updatedContent['Status'] = [
      {
        'preenchendo': _preenchendoRelatorio,
        'revisar': _revisarRelatorio,
        'aprovado': _aprovado,
      }
    ];

    // Cria um novo relatório com os dados atualizados
    return _controller.relatorio!.copyWith(
      data: _selectedDate,
      content: updatedContent,
      status: newStatus,
      sections: allSections,
    );
  }

  // Método para salvar o relatório
  void _saveRelatorio() async {
    final updatedRelatorio = _buildUpdatedRelatorio();

    final success = await _controller.saveRelatorio(updatedRelatorio);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório atualizado com sucesso')),
      );

      // Se você tem acesso ao objeto obra completo através do controller
      if (_controller.obra != null) {
        context.go('/obra_detail', extra: {
          'obra': _controller.obra,
          'initialTab':
              1 // Adicione lógica no ObraDetailPage para usar esse valor
        });
      } else {
        // Navegação alternativa se não tiver acesso à obra
        context.go('/');
      }
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
        relatorioId: _controller.relatorio?.id ?? '',
        obraId: widget.obraId,
      ),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      // Aqui não precisamos mais acessar diretamente o Firestore
      // Em vez disso, o controller irá atualizar o relatório
      await _controller.refreshMaoDeObra(
          widget.obraId, _controller.relatorio!.id!);
      _updateStateFromRelatorio(_controller.relatorio!);
    }
  }

  void _addEquipamentoItem() async {
    final selectedItems = await showDialog<List<String>>(
      context: context,
      builder: (context) => SelectEquipamentosScreen(
        selectedItems:
            _equipamentosItems.map((item) => item['title'] as String).toList(),
        relatorioId: _controller.relatorio?.id ?? '',
        obraId: widget.obraId,
      ),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      await _controller.refreshEquipamentos(
          widget.obraId, _controller.relatorio!.id!);
      _updateStateFromRelatorio(_controller.relatorio!);
    }
  }

  void _addAtividadeItem() async {
    final updatedAtividade = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAtividadeScreen(
          relatorioId: _controller.relatorio?.id ?? '',
          obraId: widget.obraId,
        ),
      ),
    );

    if (updatedAtividade != null) {
      await _controller.refreshAtividades(
          widget.obraId, _controller.relatorio!.id!);
      _updateStateFromRelatorio(_controller.relatorio!);
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
        'data': DateTime.now().toString().substring(0, 16).replaceAll('T', ' '),
        'comentario': '',
      });
    });
  }

  void _addFotoItem() {
    setState(() {
      _fotosItems.add({
        'url': '',
        'thumbnail': 'https://via.placeholder.com/100',
      });
    });
  }

  void _addVideoItem() {
    setState(() {
      _videosItems.add({
        'url': '',
        'thumbnail': 'https://via.placeholder.com/100',
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
    return Consumer<EditRelatorioController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
            ),
            body: Center(child: Text(controller.errorMessage!)),
          );
        }

        if (controller.relatorio == null || controller.obra == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dados não encontrados',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
            ),
            body: const Center(
                child: Text('Não foi possível carregar os dados do relatório')),
          );
        }

        // Interface do usuário com relatório carregado
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text(
              'Editar relatório',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navegação modificada: voltar para ObraDetailPage
                if (_controller.obra != null) {
                  // Importante: navegar para /obra_detail (página principal com tabs)
                  context.go('/obra_detail', extra: {
                    'obra': _controller.obra,
                    'initialTab':
                        1 // Adicione lógica no ObraDetailPage para usar esse valor
                  });
                } else {
                  // Navegação alternativa se a obra não estiver disponível
                  context.go('/');
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: _saveRelatorio,
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título "Detalhes do relatório" e botão "Preenchendo Relatório"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
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
                          // Lógica para preencher o relatório
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Preenchendo Relatório'),
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // Título "Relatório Diário de Obra (RDO)"
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Relatório Diário de Obra (RDO)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(),

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

                const Divider(),
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
                        controller.obra?.numeroContrato ?? 'Não informado',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Responsável',
                        controller.obra?.responsavel ?? 'Não informado',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Contratante',
                        controller.obra?.contratante ?? 'Não informado',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow(
                  'Obra',
                  controller.obra?.nome ?? 'Não informado',
                ),
                const Divider(),
                _buildDetailRow(
                  'Endereço',
                  controller.obra?.endereco ?? 'Não informado',
                ),
                const Divider(),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildEditRow(
                          'Prazo decorrido',
                          _prazoDecorrido != null
                              ? '$_prazoDecorrido dias'
                              : '0 dias',
                          readOnly: true,
                          fontTitleSize: 12),
                    ),
                    const SizedBox(width: 8),
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
                const Divider(),

                // Condição climática
                const Text(
                  'Condição climática',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção "Tempo"
                    const Text('Tempo',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const Divider(),
                    _buildWeatherRow(
                        'Manhã', _manhaSelected, _weatherManhaTempo!),
                    const Divider(),
                    _buildWeatherRow(
                        'Tarde', _tardeSelected, _weatherTardeTempo!),
                    const Divider(),
                    _buildWeatherRow(
                        'Noite', _noiteSelected, _weatherNoiteTempo!),
                    const Divider(),
                    // Seção "Condição"
                    const Text('Condição',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const Divider(),
                    _buildWeatherRow(
                        'Manhã', _manhaSelected, _weatherManhaCondicao!,
                        isCondition: true),
                    const Divider(),
                    _buildWeatherRow(
                        'Tarde', _tardeSelected, _weatherTardeCondicao!,
                        isCondition: true),
                    const Divider(),
                    _buildWeatherRow(
                        'Noite', _noiteSelected, _weatherNoiteCondicao!,
                        isCondition: true),
                    const Divider(),
                    // Índice pluviométrico
                    const Text('Índice pluviométrico',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const Divider(),
                    Row(
                      children: [
                        const Expanded(child: Text('Quantidade em "mm"')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                _indicePluviometrico?.toStringAsFixed(2) ?? '',
                            decoration: const InputDecoration(
                              hintText: 'Ex.: 5,30',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
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
                    const Divider(),
                    // Mão de obra
                    _buildSection(
                        'Mão de obra', _maoDeObraItems, _addMaoDeObraItem),
                    const Divider(),

                    // Equipamentos
                    _buildSection('Equipamentos', _equipamentosItems,
                        _addEquipamentoItem),
                    const Divider(),

                    // Atividades
                    _buildSectionWithDetails(
                        'Atividades', _atividadesItems, _addAtividadeItem),
                    const Divider(),

                    // Ocorrências
                    _buildSectionWithDetails(
                        'Ocorrências', _ocorrenciasItems, _addOcorrenciaItem),
                    const Divider(),
                    // Comentários
                    _buildSectionWithComments(
                        'Comentários', _comentariosItems, _addComentarioItem),
                    const Divider(),

                    // Fotos
                    _buildSectionWithMedia('Fotos', _fotosItems, _addFotoItem,
                        isVideo: false),
                    const Divider(),

                    // Vídeos
                    _buildSectionWithMedia(
                        'Vídeos', _videosItems, _addVideoItem,
                        isVideo: true),
                    const Divider(),

                    // Anexos
                    _buildSectionWithAttachments(
                        'Anexos', _anexosItems, _addAnexoItem),
                    const Divider(),
                    // Status relatorio
                    const Text(
                      'Status Relatório',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        const Text('Preenchendo Relatório'),
                      ],
                    ),
                    const Divider(),
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
                        const Text('Revisar Relatório'),
                      ],
                    ),
                    const Divider(),
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
                        const Text('Aprovado'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget para criar linhas de informação
  Widget _buildDetailRow(String label, String value,
      {bool isStatus = false,
      bool isBold = true,
      double fontSizeTitle = 16,
      double fontSizeSubTitle = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 12),
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            disabledHint: Text(value),
          ),
        ),
      ],
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
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
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
        const SizedBox(height: 8),
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
                          title: const Text("Excluir Item"),
                          content: const Text(
                              "Tem certeza que deseja excluir este item?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fecha o diálogo
                              },
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Lógica para excluir o item
                                setState(() {
                                  items.remove(item); // Remove o item da lista
                                });
                                Navigator.of(context).pop(); // Fecha o diálogo
                              },
                              child: const Text(
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
                    decoration: const InputDecoration(
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
              const Divider(), // Adiciona uma linha entre os itens
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
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
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
        const SizedBox(height: 8),
        ...items.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: item['title'] as String?,
                decoration: const InputDecoration(
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
              const SizedBox(height: 8),
              TextFormField(
                initialValue: item['descricao'] as String?,
                decoration: const InputDecoration(
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
                        decoration: const InputDecoration(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['status'] as String?,
                        decoration: const InputDecoration(
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
                const SizedBox(height: 8),
                _buildMemberSection(
                    'Membros', item['membros'] as List<Map<String, dynamic>>),
              ],
              if (title == 'Ocorrências') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['duracao'] as String?,
                        decoration: const InputDecoration(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['impacto'] as String?,
                        decoration: const InputDecoration(
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
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: item['condicao'] as String?,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 8),
                _buildMemberSection(
                    'Membros', item['membros'] as List<Map<String, dynamic>>),
              ],
              if (item['foto'] != null && item['foto'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    item['foto'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 100);
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
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        ...members.map((member) {
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: member['title'] as String?,
                  decoration: const InputDecoration(
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
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: (member['quantidade'] as int?)?.toString(),
                  decoration: const InputDecoration(
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
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
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
        const SizedBox(height: 8),
        ...items.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: item['autor'] as String?,
                decoration: const InputDecoration(
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
              const SizedBox(height: 8),
              TextFormField(
                initialValue: item['data'] as String?,
                decoration: const InputDecoration(
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
              const SizedBox(height: 8),
              TextFormField(
                initialValue: item['comentario'] as String?,
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
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
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
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
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                          return const Icon(Icons.image_not_supported,
                              size: 100);
                        },
                      ),
                      if (isVideo)
                        const Center(
                          child: Icon(Icons.play_arrow,
                              color: Colors.white, size: 40),
                        ),
                      if (isVideo)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Text(
                            item['duracao'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                backgroundColor: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['url'] as String?,
                    decoration: const InputDecoration(
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
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
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
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['nome'] as String?,
                    decoration: const InputDecoration(
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['url'] as String?,
                    decoration: const InputDecoration(
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
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () {
                    // Lógica para download do anexo
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
