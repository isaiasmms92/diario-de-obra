// features/relatorio/presentation/pages/view_relatorio_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../obra/data/models/obra_model.dart';
import '../../../obra/domain/entities/obra.dart';
import '../../domain/entities/relatorio.dart';
import '../controllers/relatorio_controller.dart';
import '../widgets/clima_widget.dart';
import '../widgets/secao_relatorio_widget.dart';

class ViewRelatorioPage extends StatefulWidget {
  final Relatorio relatorio;
  final Obra? obra;
  final String? obraId;

  const ViewRelatorioPage({
    Key? key,
    required this.relatorio,
    this.obra,
    this.obraId,
  })  : assert(obra != null || obraId != null),
        super(key: key);

  @override
  _ViewRelatorioPageState createState() => _ViewRelatorioPageState();
}

class _ViewRelatorioPageState extends State<ViewRelatorioPage> {
  late final RelatorioController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  Obra? _obra;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<RelatorioController>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.obra != null) {
        _obra = widget.obra;
      } else if (widget.obraId != null) {
        _obra = await _controller.loadObra(widget.obraId!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            '${widget.relatorio.data.day}/${widget.relatorio.data.month}/${widget.relatorio.data.year}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            '${widget.relatorio.data.day}/${widget.relatorio.data.month}/${widget.relatorio.data.year}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final relatorio = widget.relatorio;
    final obra = _obra;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          '${relatorio.data.day}/${relatorio.data.month}/${relatorio.data.year}',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Voltamos para a tela de relatórios com a obra carregada, se disponível
            if (obra is ObraModel) {
              context.go('/obra_detail/relatorios', extra: obra);
            } else if (obra != null) {
              context.go('/obra/${obra.id}/relatorios');
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com título e botão de edição
            _buildCabecalho(context, relatorio, obra),
            const Divider(),

            // Título do relatório
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Relatório Diário de Obra (RDO)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),

            // Detalhes do relatório
            _buildDetailRow('Data', _formatarData(relatorio.data)),
            const Divider(),

            // Detalhes da obra
            if (obra != null)
              _buildObraDetails(obra)
            else
              const Text('Dados da obra não disponíveis'),

            const Divider(),

            // Condições climáticas
            _buildCondicoesClimaticas(relatorio),

            const SizedBox(height: 16),

            // Seções do relatório
            ...relatorio.sections.map((section) {
              final content = relatorio.content[section] ?? [];
              return SecaoRelatorioWidget(
                titulo: '$section (${content.length})',
                conteudo: content,
              );
            }).toList(),

            const SizedBox(height: 16),

            // Assinatura
            _buildAssinatura(),

            const SizedBox(height: 16),

            // Informações adicionais
            _buildInformacoesAdicionais(relatorio),

            const SizedBox(height: 16),

            // Navegação entre relatórios
            _buildNavegacaoRelatorios(context, relatorio, obra),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho(
      BuildContext context, Relatorio relatorio, Obra? obra) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Detalhes do relatório',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        SizedBox(
          height: 35,
          child: ElevatedButton(
            onPressed: () {
              if (obra is ObraModel) {
                context.go('/obra_detail/edit-relatorio',
                    extra: {'relatorio': relatorio, 'obra': obra});
              } else if (obra != null) {
                context.go('/obra/${obra.id}/edit-relatorio', extra: relatorio);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Preenchendo Relatório'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBold = true,
    double fontSizeTitle = 16,
    double fontSizeSubTitle = 14,
  }) {
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

  Widget _buildObraDetails(Obra obra) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: _buildDetailRow(
                'Dia da semana', _getDayOfWeek(widget.relatorio.data)),
          ),
          Expanded(
            child: _buildDetailRow(
                'Nº do contrato', obra.numeroContrato ?? 'Não informado'),
          ),
        ]),
        const Divider(),
        Row(children: [
          Expanded(
            child: _buildDetailRow(
                'Responsável', obra.responsavel ?? 'Não informado'),
          ),
          Expanded(
            child: _buildDetailRow(
                'Contratante', obra.contratante ?? 'Não informado'),
          ),
        ]),
        const Divider(),
        Row(children: [
          Expanded(
              child: _buildDetailRow('Obra', obra.nome ?? 'Não informado')),
        ]),
        const Divider(),
        Row(children: [
          Expanded(
              child: _buildDetailRow(
                  'Endereço', obra.endereco ?? 'Não informado')),
        ]),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildDetailRow(
                'Prazo contratual',
                obra.formatarPrazo(obra.prazoContratual),
                fontSizeTitle: 14,
              ),
            ),
            Expanded(
              child: _buildDetailRow(
                'Prazo decorrido',
                obra.formatarPrazo(obra.prazoDecorrido),
                fontSizeTitle: 14,
              ),
            ),
            Expanded(
              child: _buildDetailRow(
                'Prazo a vencer',
                obra.formatarPrazo(obra.prazoVencer),
                fontSizeTitle: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCondicoesClimaticas(Relatorio relatorio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condição climática',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        ClimaWidget(relatorio: relatorio),
      ],
    );
  }

  Widget _buildAssinatura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assinatura manual',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            'Assinatura',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesAdicionais(Relatorio relatorio) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Criado por: ${relatorio.createdAt != null ? _formatarDataHora(relatorio.createdAt!) : "Não informado"}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Última modificação: ${relatorio.createdAt != null ? _formatarDataHora(relatorio.createdAt!) : "Não informado"}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNavegacaoRelatorios(
      BuildContext context, Relatorio relatorio, Obra? obra) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        OutlinedButton(
          onPressed: () {
            // Lógica para navegação entre relatórios
            // A implementar: busca pelo relatório anterior
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Anterior ${_formatarData(relatorio.data)}'),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _formatarDataHora(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    final diasDaSemana = [
      'Segunda-Feira',
      'Terça-Feira',
      'Quarta-Feira',
      'Quinta-Feira',
      'Sexta-Feira',
      'Sábado',
      'Domingo',
    ];

    // O weekday no DateTime começa em 1 (Segunda) e vai até 7 (Domingo)
    return diasDaSemana[date.weekday - 1];
  }
}
