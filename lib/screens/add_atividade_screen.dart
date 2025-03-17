import 'package:app_diario_obra/screens/select_mao_de_obra_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar horas

class AddAtividadeScreen extends StatefulWidget {
  final Map<String, dynamic>?
      atividade; // Atividade existente para edição (opcional)
  final String relatorioId; // ID do relatório para salvar no Firestore
  final String obraId; // ID da obra para salvar no Firestore

  const AddAtividadeScreen({
    Key? key,
    this.atividade,
    required this.relatorioId,
    required this.obraId,
  }) : super(key: key);

  @override
  _AddAtividadeScreenState createState() => _AddAtividadeScreenState();
}

class _AddAtividadeScreenState extends State<AddAtividadeScreen> {
  final TextEditingController _descricaoController = TextEditingController();
  bool _exibirMaisOpcoes = false;
  final TextEditingController _qtdRealizadaController = TextEditingController();
  final TextEditingController _unidadeController = TextEditingController();
  final TextEditingController _porcentagemController = TextEditingController();
  String _status = 'Em andamento';
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  String _totalHoras = '00:00'; // Calculado automaticamente
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _statusOptions = [
    'Em andamento',
    'Concluído',
    'Pausado'
  ];
  String? _fotoUrl; // URL ou caminho da foto
  List<Map<String, dynamic>> _membros =
      []; // Lista de mãos de obra associadas à ativ

  @override
  void initState() {
    super.initState();
    // Inicializa com dados existentes, se houver
    if (widget.atividade != null) {
      _descricaoController.text =
          widget.atividade!['descricao'] as String? ?? '';
      _exibirMaisOpcoes = widget.atividade!.containsKey('progresso') ||
          widget.atividade!.containsKey('status') ||
          widget.atividade!.containsKey('qtdRealizada') ||
          widget.atividade!.containsKey('unidade') ||
          widget.atividade!.containsKey('horaInicio') ||
          widget.atividade!.containsKey('horaFim');
      _qtdRealizadaController.text =
          widget.atividade!['qtdRealizada']?.toString() ?? '';
      _unidadeController.text = widget.atividade!['unidade'] as String? ?? '';
      _porcentagemController.text =
          widget.atividade!['progresso']?.toStringAsFixed(0) ?? '';
      _status = widget.atividade!['status'] as String? ?? 'Em andamento';
      _horaInicioController.text =
          _formatTime(widget.atividade!['horaInicio'] as String? ?? '00:00');
      _horaFimController.text =
          _formatTime(widget.atividade!['horaFim'] as String? ?? '00:00');
      _totalHoras =
          widget.atividade!['totalHoras'] as String? ?? _calculateTotalHoras();
      _fotoUrl = widget.atividade!['foto'] as String?;
      _membros = (widget.atividade!['membros'] as List<dynamic>?)
              ?.map((m) => {
                    'title': m['title'] as String? ?? '',
                    'quantidade': (m['quantidade'] as num?)?.toInt() ?? 1,
                  })
              .toList() ??
          [];
    } else {
      _descricaoController.text = '';
      _qtdRealizadaController.text = ''; // Valor padrão
      _unidadeController.text = ''; // Valor padrão
      _porcentagemController.text = ''; // Valor padrão
      _status = 'Em andamento';
      _horaInicioController.text = '';
      _horaFimController.text = '';
      _totalHoras = '00:00';
      _fotoUrl = null;
      _membros = [];
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _qtdRealizadaController.dispose();
    _unidadeController.dispose();
    _porcentagemController.dispose();
    _horaInicioController.dispose();
    _horaFimController.dispose();
    super.dispose();
  }

  void _toggleExibirMaisOpcoes(bool? value) {
    setState(() {
      _exibirMaisOpcoes = value ?? false;
      if (!_exibirMaisOpcoes) {
        _qtdRealizadaController.clear();
        _unidadeController.clear();
        _porcentagemController.text = '0';
        _status = 'Em andamento';
        _horaInicioController.text = '';
        _horaFimController.text = '';
        _totalHoras = '00:00';
      }
    });
  }

  String _formatTime(String input) {
    // Formata entrada como "hh:mm" (ex.: "1000" → "10:00", "830" → "08:30")
    try {
      String cleanInput =
          input.replaceAll(RegExp(r'[^0-9]'), ''); // Remove não numéricos
      if (cleanInput.length == 4) {
        // Formato "hhmm" (ex.: 1000, 0830)
        final hours = cleanInput.substring(0, 2);
        final minutes = cleanInput.substring(2);
        return '$hours:$minutes';
      } else if (cleanInput.length == 3) {
        // Formato "hmm" (ex.: 830 → 08:30)
        final hours = cleanInput.padLeft(2, '0').substring(0, 2);
        final minutes = cleanInput.substring(cleanInput.length - 2);
        return '$hours:$minutes';
      } else if (cleanInput.length == 2) {
        // Formato "mm" (ex.: 30 → 00:30)
        return '00:${cleanInput.padLeft(2, '0')}';
      } else {
        // Formato inválido, retorna "00:00" ou o input formatado
        final parts = input.split(':');
        if (parts.length == 2) {
          final hours =
              int.tryParse(parts[0])?.toString().padLeft(2, '0') ?? '00';
          final minutes =
              int.tryParse(parts[1])?.toString().padLeft(2, '0') ?? '00';
          return '$hours:$minutes';
        }
        return '00:00';
      }
    } catch (e) {
      return '00:00';
    }
  }

  String _calculateTotalHoras() {
    try {
      final inicio = TimeOfDay.fromDateTime(
          DateFormat('HH:mm').parse(_horaInicioController.text));
      final fim = TimeOfDay.fromDateTime(
          DateFormat('HH:mm').parse(_horaFimController.text));

      final inicioMinutes = inicio.hour * 60 + inicio.minute;
      final fimMinutes = fim.hour * 60 + fim.minute;

      int totalMinutes = fimMinutes - inicioMinutes;
      if (totalMinutes < 0) totalMinutes += 24 * 60; // Caso passe da meia-noite

      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      final relatorioRef = _firestore
          .collection('obras')
          .doc(widget.obraId)
          .collection('relatorios')
          .doc(widget.relatorioId);

      final atividadeData = {
        'title': _descricaoController.text.isEmpty
            ? 'Atividade'
            : _descricaoController.text.split('\n').first,
        'descricao': _descricaoController.text,
        'membros': _membros, // Mãos de obra associadas
        'foto': _fotoUrl ?? '', // URL ou caminho da foto
      };

      if (_exibirMaisOpcoes) {
        atividadeData['qtdRealizada'] =
            double.tryParse(_qtdRealizadaController.text) ?? 0.0;
        atividadeData['unidade'] = _unidadeController.text;
        atividadeData['progresso'] =
            double.tryParse(_porcentagemController.text.replaceAll('%', '')) ??
                0.0;
        atividadeData['status'] = _status;
        atividadeData['horaInicio'] = _horaInicioController.text;
        atividadeData['horaFim'] = _horaFimController.text;
        atividadeData['totalHoras'] = _calculateTotalHoras();
      }

      // Busca o content atual para mesclar
      final relatorioSnapshot = await relatorioRef.get();
      if (relatorioSnapshot.exists) {
        final currentContent =
            (relatorioSnapshot.data() as Map<String, dynamic>? ?? {})['content']
                    as Map<String, dynamic>? ??
                {};
        final atividades = (currentContent['Atividades'] as List<dynamic>?)
                ?.map((item) => Map<String, dynamic>.from(item as Map))
                .toList() ??
            [];

        // Adiciona ou atualiza a atividade
        if (widget.atividade != null) {
          final index = atividades.indexWhere(
              (item) => item['title'] == widget.atividade!['title']);
          if (index != -1) {
            atividades[index] = atividadeData;
          }
        } else {
          atividades.add(atividadeData);
        }

        await relatorioRef.update({
          'content.Atividades': atividades,
        });
      } else {
        await relatorioRef.set({
          'content': {
            'Atividades': [atividadeData],
          },
        }, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade salva com sucesso')),
      );
      Navigator.pop(context, atividadeData); // Retorna a atividade atualizada
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
    }
  }

  Future<void> _addMaoDeObra() async {
    final maoDeObraFromRelatorio = await _firestore
        .collection('obras')
        .doc(widget.obraId)
        .collection('relatorios')
        .doc(widget.relatorioId)
        .get();

    if (maoDeObraFromRelatorio.exists) {
      final selectedMaoDeObra = await showDialog<List<String>>(
        context: context,
        builder: (context) => SelectMaoDeObraScreen(
          selectedItems: _membros.map((m) => m['title'] as String).toList(),
          relatorioId: widget.relatorioId,
          obraId: widget.obraId,
        ),
      );

      if (selectedMaoDeObra != null && selectedMaoDeObra.isNotEmpty) {
        setState(() {
          _membros = selectedMaoDeObra
              .map((title) => {
                    'title': title,
                    'quantidade': 1, // Quantidade padrão
                  })
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Adicionar atividade',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveToFirestore,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Descrição',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                maxLines: 5, // Multilinha para descrição
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _exibirMaisOpcoes,
                    onChanged: _toggleExibirMaisOpcoes,
                    activeColor: Colors.blue,
                  ),
                  const Text('Exibir mais opções'),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Porcentagem',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _porcentagemController,
                          decoration: InputDecoration(
                            hintText: 'Ex.: 10%',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            suffixText: '%',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Remove caracteres não numéricos, exceto '%'
                            final newValue =
                                value.replaceAll(RegExp(r'[^\d%]'), '');
                            if (newValue != value) {
                              _porcentagemController.text = newValue;
                              _porcentagemController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: newValue.length),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _status,
                          items: _statusOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _status = value ?? 'Em andamento';
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_exibirMaisOpcoes) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Qtd. Realizada',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextField(
                            controller: _qtdRealizadaController,
                            decoration: InputDecoration(
                              hintText: 'Ex.: 90.5',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unidade',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextField(
                            controller: _unidadeController,
                            decoration: InputDecoration(
                              hintText: 'Ex.: m²',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora início',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextField(
                            controller: _horaInicioController,
                            decoration: InputDecoration(
                              hintText: 'hh:mm',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            keyboardType: TextInputType.datetime,
                            onChanged: (value) {
                              setState(() {
                                _horaInicioController.text = _formatTime(value);
                                _totalHoras = _calculateTotalHoras();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora fim',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextField(
                            controller: _horaFimController,
                            decoration: InputDecoration(
                              hintText: 'hh:mm',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            keyboardType: TextInputType.datetime,
                            onChanged: (value) {
                              setState(() {
                                _horaFimController.text = _formatTime(value);
                                _totalHoras = _calculateTotalHoras();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total de horas',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextField(
                            controller:
                                TextEditingController(text: _totalHoras),
                            decoration: InputDecoration(
                              hintText: 'hh:mm',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            enabled:
                                false, // Campo só leitura, calculado automaticamente
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                // Adicione seções para "Mão de obra" e "Fotos" como na imagem (simplificado)
                _buildSection('Mão de obra', _membros,
                    _addMaoDeObra), // Placeholder, substitua por lógica real
                _buildSection('Fotos', [],
                    () {}), // Placeholder, substitua por lógica real
              ],
            ],
          ),
        ),
      ),
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
        Divider(),
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
                  width: 80, // Define a largura do TextFormField
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
}
