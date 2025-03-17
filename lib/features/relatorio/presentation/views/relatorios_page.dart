// features/relatorio/presentation/pages/relatorios_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../obra/domain/entities/obra.dart';
import '../controllers/relatorio_controller.dart';
import '../../domain/entities/relatorio.dart';
import '../../../obra/data/models/obra_model.dart';
import '../widgets/relatorio_item_widget.dart';
import '../widgets/relatorio_options_bottom_sheet.dart';

class RelatoriosPage extends StatefulWidget {
  final ObraModel? obra;
  final String? obraId;

  const RelatoriosPage({
    super.key,
    this.obra,
    this.obraId,
  });

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  @override
  void initState() {
    super.initState();
    // Inicializa o controller com a obra ou o ID da obra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<RelatorioController>(context, listen: false);
      controller.initialize(obra: widget.obra, obraId: widget.obraId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RelatorioController>(
      builder: (context, controller, _) {
        final obra = controller.obra;

        if (controller.isLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: const Text('Relatórios',
                  style: TextStyle(color: Colors.white)),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: const Text('Relatórios',
                  style: TextStyle(color: Colors.white)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.obraId != null) {
                        controller.initialize(obraId: widget.obraId);
                      } else {
                        context.go('/');
                      }
                    },
                    child: Text(
                        widget.obraId != null ? 'Tentar novamente' : 'Voltar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (obra == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: const Text('Relatórios',
                  style: TextStyle(color: Colors.white)),
            ),
            body: const Center(
              child: Text('Obra não disponível'),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Relatórios',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // Lógica para abrir os filtros
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'FILTROS',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildRelatoriosList(context, controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatoriosList(
      BuildContext context, RelatorioController controller) {
    final relatorios = controller.relatorios;
    final obra = controller.obra;

    if (relatorios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Nenhum relatório encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Adicione novos relatórios ou altere o filtro de busca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: relatorios.length,
      itemBuilder: (context, index) {
        final relatorio = relatorios[index];
        return RelatorioItemWidget(
          relatorio: relatorio,
          onTap: () => _showRelatorioOptions(context, relatorio, obra!),
          onEdit: () {
            if (obra is ObraModel) {
              context.go('/obra_detail/edit-relatorio',
                  extra: {'relatorio': relatorio, 'obra': obra});
            } else {
              context.go('/obra/${obra!.id}/edit-relatorio', extra: relatorio);
            }
          },
        );
      },
    );
  }

  void _showRelatorioOptions(
      BuildContext context, Relatorio relatorio, Obra obra) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return RelatorioOptionsBottomSheet(
          onView: () {
            Navigator.pop(context);
            if (obra is ObraModel) {
              context.go('/obra_detail/view-relatorio',
                  extra: {'relatorio': relatorio, 'obra': obra});
            } else {
              context.go('/obra/${obra.id}/view-relatorio', extra: relatorio);
            }
          },
          onEdit: () {
            Navigator.pop(context);
            if (obra is ObraModel) {
              context.go('/obra_detail/edit-relatorio',
                  extra: {'relatorio': relatorio, 'obra': obra});
            } else {
              context.go('/obra/${obra.id}/edit-relatorio', extra: relatorio);
            }
          },
          onPrint: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Função de impressão em PDF não implementada')),
            );
          },
          onDelete: () {
            Navigator.pop(context);
            _showDeleteConfirmation(context, relatorio);
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Relatorio relatorio) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Relatório'),
          content: const Text('Tem certeza que deseja excluir este relatório?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final controller =
                    Provider.of<RelatorioController>(context, listen: false);
                controller.deleteRelatorio(relatorio.id!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Relatório excluído com sucesso')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erro ao excluir relatório: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
