import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/obra/data/models/obra_model.dart';
import '../features/relatorio/data/models/relatorio_model.dart';

class AddRelatorioScreen extends StatefulWidget {
  final ObraModel? obra; // Recebe a obra como parâmetro, opcional

  const AddRelatorioScreen({this.obra});

  @override
  _AddRelatorioScreenState createState() => _AddRelatorioScreenState();
}

class _AddRelatorioScreenState extends State<AddRelatorioScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedObraId; // ID da obra selecionada no Firestore
  DateTime? _selectedDate = DateTime.now(); // Data inicial como hoje
  bool _copyLastReport =
      true; // Checkbox "Copiar informações do último relatório"
  final String _content = ''; // Novo campo para o conteúdo do relatório
  bool _showCopiedSections =
      true; // Controla se as seções copiadas estão visíveis
  final List<String> _reportSections = [
    'Condição Climática',
    'Mão de Obra',
    'Equipamentos',
    'Atividades',
    'Ocorrências',
    'Controle de Materiais',
    'Comentários',
    'Fotos',
    'Videos',
    'Anexos'
  ];
  final List<bool> _sectionChecked =
      List<bool>.filled(10, true); // Inicializa todas como verdadeiras

  late AnimationController _animationController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Se uma obra for passada como parâmetro, pré-seleciona ela
    if (widget.obra != null) {
      _selectedObraId = widget.obra!.id;
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Adicionar relatório',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/obra_detail/relatorios',
                extra: widget.obra); // Volta para a tela de relatórios
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveReport, // Função para salvar o relatório
            child: Text(
              'Salvar',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('obras').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar obras'));
              }

              final obras = snapshot.data!.docs
                  .map((doc) => ObraModel.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione a obra',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedObraId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    items: obras.map((obra) {
                      return DropdownMenuItem<String>(
                        value: obra.id,
                        child: Text(obra.nome ?? 'Obra sem nome'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedObraId = value;
                      });
                    },
                    hint: Text('Selecione a obra'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Data',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      hintText: 'dd/mm/aaaa',
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          : '',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Copiar informações do último relatório',
                        style: TextStyle(fontSize: 14),
                      ),
                      Checkbox(
                        value: _copyLastReport,
                        onChanged: (value) {
                          setState(() {
                            _copyLastReport = value ?? false;
                            if (!_copyLastReport)
                              _showCopiedSections =
                                  false; // Esconde as seções se desmarcar
                            if (_copyLastReport && !_showCopiedSections) {
                              _showCopiedSections =
                                  true; // Mostra as seções ao marcar
                              _animationController.forward(from: 0.0);
                            }
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      if (_copyLastReport)
                        IconButton(
                          icon: Icon(
                            _showCopiedSections
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showCopiedSections = !_showCopiedSections;
                              if (_showCopiedSections) {
                                _animationController.forward(from: 0.0);
                              } else {
                                _animationController.reverse();
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  if (_copyLastReport)
                    SizeTransition(
                      sizeFactor: CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          ..._reportSections.asMap().entries.map((entry) {
                            int index = entry.key;
                            String section = entry.value;
                            return CheckboxListTile(
                              title: Text(section),
                              value: _sectionChecked[index],
                              onChanged: (value) {
                                setState(() {
                                  _sectionChecked[index] = value ?? false;
                                });
                              },
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _saveReport() {
    if (_selectedObraId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione uma obra e uma data')),
      );
      return;
    }

    // Aqui, ao invés de usar apenas as seções selecionadas, usamos a lista completa de seções
    final selectedSections = _reportSections;

    // Cria um mapa de conteúdo onde cada seção é inicialmente uma lista vazia do tipo List<dynamic>
    Map<String, List<dynamic>> content = Map.fromIterable(
      selectedSections,
      key: (section) => section,
      value: (section) =>
          <dynamic>[], // Inicializa cada seção como uma lista vazia de tipo dynamic
    );

    final relatorio = RelatorioModel(
      obraId: _selectedObraId!, // Vincula o ID da obra selecionada
      data: _selectedDate!,
      sections: selectedSections,
      copyLast: _copyLastReport,
      content: content, // Agora o tipo está correto
    );

    _firestore
        .collection('obras')
        .doc(_selectedObraId)
        .collection('relatorios')
        .add(relatorio.toMap())
        .then((value) {
      context.go('/obra_detail/relatorios', extra: widget.obra);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar relatório: $error')),
      );
    });
  }
}
