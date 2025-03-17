import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectMaoDeObraScreen extends StatefulWidget {
  final List<String> selectedItems; // Lista de itens já selecionados (opcional)
  final String relatorioId; // ID do relatório para salvar no Firestore
  final String obraId; // ID da obra para salvar no Firestore

  const SelectMaoDeObraScreen({
    Key? key,
    this.selectedItems = const [],
    required this.relatorioId,
    required this.obraId,
  }) : super(key: key);

  @override
  _SelectMaoDeObraScreenState createState() => _SelectMaoDeObraScreenState();
}

class _SelectMaoDeObraScreenState extends State<SelectMaoDeObraScreen> {
  final List<String> _maoDeObraOptions = [
    'Ajudante',
    'Eletricista',
    'Engenheiro',
    'Estagiário',
    'Gesseiro',
    'Mestre de Obra',
    'Pedreiro',
    'Servente',
    'Técnico em Edificações',
  ];

  List<String> _selectedItems = [];
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedItems =
        List.from(widget.selectedItems); // Inicializa com itens já selecionados
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _saveToFirestore() async {
    try {
      // Atualiza o content['Mão de obra'] no relatório
      final relatorioRef = _firestore
          .collection('obras')
          .doc(widget.obraId)
          .collection('relatorios')
          .doc(widget.relatorioId);

      await relatorioRef.update({
        'content.Mão de obra': _selectedItems
            .map((title) => {
                  'title': title,
                  'quantidade': 1, // Quantidade padrão como 1
                })
            .toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mão de obra salva com sucesso')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
      throw error; // Propaga o erro para ser tratado no caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, _selectedItems); // Retorna os itens selecionados ao fechar
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Selecione as mão de obra',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () =>
                Navigator.pop(context, _selectedItems), // Retorna ao fechar
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _saveToFirestore();
                  Navigator.pop(
                      context, _selectedItems); // Retorna os itens salvos
                } catch (e) {
                  // Erro já tratado em _saveToFirestore
                }
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo de busca
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Filtro de busca...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              // Lista de checkboxes para mão de obra
              Expanded(
                child: ListView(
                  children: _maoDeObraOptions
                      .where((option) => option
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .map((option) => CheckboxListTile(
                            title: Text(option),
                            value: _selectedItems.contains(option),
                            onChanged: (value) => _onItemTapped(option),
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
