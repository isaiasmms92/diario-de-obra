import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/obra_model.dart';
import '../controllers/obra_controller.dart';

class AddObraPage extends StatefulWidget {
  const AddObraPage({super.key});

  @override
  _AddObraPageState createState() => _AddObraPageState();
}

class _AddObraPageState extends State<AddObraPage> {
  final _formKey = GlobalKey<FormState>();
  bool cadastroCompleto = true;
  bool listaTarefas = false;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController contratanteController = TextEditingController();
  final TextEditingController dataInicioController = TextEditingController();
  final TextEditingController previsaoTerminoController =
      TextEditingController();
  final TextEditingController numeroContratoController =
      TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  String status = 'Em andamento';

  bool _isSaving = false;

  @override
  void dispose() {
    nomeController.dispose();
    responsavelController.dispose();
    contratanteController.dispose();
    dataInicioController.dispose();
    previsaoTerminoController.dispose();
    numeroContratoController.dispose();
    enderecoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Adicionar obra',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/'); // Volta para a tela inicial
          },
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveObra,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: cadastroCompleto,
                      onChanged: (value) {
                        setState(() {
                          cadastroCompleto = value ?? true;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    const Text(
                      'Cadastro completo',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Checkbox(
                      value: !cadastroCompleto,
                      onChanged: (value) {
                        setState(() {
                          cadastroCompleto = !(value ?? false);
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    const Text(
                      'Cadastro simples',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nome (sempre visível)
                _buildTextField(
                  label: 'Nome',
                  controller: nomeController,
                  hintText: 'Ex.: Shopping Santa Luzia',
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Por favor, insira o nome da obra'
                      : null,
                ),
                // Responsável (visível apenas em Cadastro completo)
                if (cadastroCompleto)
                  _buildTextField(
                    label: 'Responsável',
                    controller: responsavelController,
                    hintText: 'Ex.: Eng. Carlos Silva',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Por favor, insira o responsável'
                        : null,
                  ),
                // Contratante (visível apenas em Cadastro completo)
                if (cadastroCompleto)
                  _buildTextField(
                    label: 'Contratante',
                    controller: contratanteController,
                    hintText: 'Ex.: Prefeitura',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Por favor, insira o contratante'
                        : null,
                  ),
                // Data início e Previsão de término (visível apenas em Cadastro completo)
                if (cadastroCompleto) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Data início',
                          controller: dataInicioController,
                          onTap: () =>
                              _selectDate(context, dataInicioController),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Por favor, insira a data de início'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Previsão de término',
                          controller: previsaoTerminoController,
                          onTap: () =>
                              _selectDate(context, previsaoTerminoController),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Por favor, insira a previsão de término'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
                // Nº do contrato e Status (visível apenas em Cadastro completo)
                if (cadastroCompleto) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Nº do contrato',
                          controller: numeroContratoController,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Por favor, insira o número do contrato'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusField(),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  _buildStatusField(),
                ],
                // Endereço (visível apenas em Cadastro completo)
                if (cadastroCompleto)
                  _buildTextField(
                    label: 'Endereço',
                    controller: enderecoController,
                    hintText: 'Ex.: Av. ABC, 100, Centro',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Por favor, insira o endereço'
                        : null,
                  ),

                // Observações (visível apenas em Cadastro completo)
                if (cadastroCompleto)
                  _buildTextField(
                    label: 'Observações',
                    controller: observacaoController,
                    hintText: 'Ex.: Observações sobre a obra',
                    maxLines: 3,
                  ),

                // Configurações (sempre visível)
                const SizedBox(height: 24),
                const Text(
                  'Configurações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lista de tarefas',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Switch(
                      value: listaTarefas,
                      onChanged: (value) {
                        setState(() {
                          listaTarefas = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'dd/mm/aaaa',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: onTap,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: TextEditingController(text: status),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          readOnly: true,
          onTap: () => _showStatusBottomSheet(context),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Por favor, selecione o status' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Selecionar status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, color: Colors.black87),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Não iniciada'),
                leading: Radio<String>(
                  value: 'Não iniciada',
                  groupValue: status,
                  onChanged: (String? value) {
                    setState(() {
                      status = value ?? 'Em andamento';
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Paralisada'),
                leading: Radio<String>(
                  value: 'Paralisada',
                  groupValue: status,
                  onChanged: (String? value) {
                    setState(() {
                      status = value ?? 'Em andamento';
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Em andamento'),
                leading: Radio<String>(
                  value: 'Em andamento',
                  groupValue: status,
                  onChanged: (String? value) {
                    setState(() {
                      status = value ?? 'Em andamento';
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Concluída'),
                leading: Radio<String>(
                  value: 'Concluída',
                  groupValue: status,
                  onChanged: (String? value) {
                    setState(() {
                      status = value ?? 'Em andamento';
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveObra() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Criamos um objeto ObraModel a partir dos dados do formulário
        final obra = ObraModel(
          nome: nomeController.text,
          status: status,
          numeroContrato:
              cadastroCompleto ? numeroContratoController.text : null,
          responsavel: cadastroCompleto ? responsavelController.text : null,
          contratante: cadastroCompleto ? contratanteController.text : null,
          dataInicio: cadastroCompleto ? dataInicioController.text : null,
          previsaoTermino:
              cadastroCompleto ? previsaoTerminoController.text : null,
          endereco: cadastroCompleto ? enderecoController.text : null,
          observacao: cadastroCompleto ? observacaoController.text : null,
          // Os prazos serão calculados automaticamente no repositório
          prazoContratual: null,
          prazoDecorrido: null,
          prazoVencer: null,
          fotoUrl: null,
          relatoriosCount: 0,
        );

        // Usamos o caso de uso através do controller para salvar a obra
        final controller = Provider.of<ObraController>(context, listen: false);
        await controller.saveObra(obra);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obra adicionada com sucesso!')),
        );
        context.go('/'); // Volta para a tela inicial após salvar
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar obra: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
