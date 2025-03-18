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
  final bool isEmbedded; // Nova propriedade para saber se está dentro de tab

  const RelatoriosPage({
    super.key,
    this.obra,
    this.obraId,
    this.isEmbedded = false, // Padrão: não está dentro de tab
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

        // Conteúdo principal
        Widget content;

        if (controller.isLoading) {
          content = const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          content = Center(
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
          );
        }

        if (obra == null) {
          content = const Center(child: Text('Obra não disponível'));
        } else {
          content = Column(
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
          );
        }
        // Se não estiver embutido em uma tab, envolve com Scaffold
        if (!widget.isEmbedded) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: obra != null
                  ? Text(obra.nome ?? 'Relatórios',
                      style: const TextStyle(color: Colors.white))
                  : const Text('Relatórios',
                      style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (obra is ObraModel) {
                    context.go('/obra_detail', extra: obra);
                  } else if (obra != null) {
                    context.go('/obra/${obra.id}');
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
            body: SafeArea(child: content),
          );
        } else {
          // Quando embutido em uma tab, retorna apenas o conteúdo
          return content;
        }
      },
    );
  }

  Widget _buildRelatoriosList(
      BuildContext context, RelatorioController controller) {
    final relatorios = controller.relatorios;
    final obra = controller.obra;

    if (relatorios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum relatório encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Adicione novos relatórios ou altere o filtro de busca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            IconButton(
                onPressed: () {
                  _navegarParaAddRelatorio(context, obra);
                },
                icon: const Icon(Icons.add))
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
              context
                  .go('/obra_detail/edit-relatorio/${obra.id}/${relatorio.id}');
            } else {
              context.go('/obra/${obra!.id}/edit-relatorio', extra: relatorio);
            }
          },
        );
      },
    );
  }

  // Método auxiliar para navegar para a tela de adição de relatório
  void _navegarParaAddRelatorio(BuildContext context, Obra? obra) {
    if (obra == null) return;

    if (obra is ObraModel) {
      context.go('/obra_detail/add-relatorio', extra: obra);
    } else {
      context.go('/obra/${obra.id}/add-relatorio');
    }
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
              context
                  .go('/obra_detail/edit-relatorio/${obra.id}/${relatorio.id}');
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
