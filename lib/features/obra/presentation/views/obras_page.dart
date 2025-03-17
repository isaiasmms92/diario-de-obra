import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/obra_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/obra_list_widget.dart';

class ObrasPage extends StatefulWidget {
  const ObrasPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ObrasPageState createState() => _ObrasPageState();
}

class _ObrasPageState extends State<ObrasPage> {
  @override
  void initState() {
    super.initState();
    // Carrega as obras quando a tela é iniciada
    Future.microtask(() => context.read<ObraController>().fetchObras());
  }

  @override
  Widget build(BuildContext context) {
    final obraController = Provider.of<ObraController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);

    // Calcula a altura do BottomAppBar e FloatingActionButton
    final double bottomPadding = 80.0 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Obras', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Adicione aqui a lógica de busca, se necessário
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String result) {
              if (result == 'logout') {
                _handleLogout(context, authController);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Configurações'),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Text('Ajuda'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: obraController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : obraController.obras.isEmpty
                ? const EmptyStateWidget()
                : ObraListWidget(
                    obras: obraController.obras,
                    bottomPadding: bottomPadding,
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add-obra');
        },
        backgroundColor: Colors.orange,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Obras',
              isSelected: true,
              onTap: () {
                context.go('/');
              },
            ),
            _buildNavItem(
              icon: Icons.receipt,
              label: 'Relatórios',
              isSelected: false,
              onTap: () {
                context.go('/relatorios');
              },
            ),
            const SizedBox(width: 48), // Espaço para o FloatingActionButton
            _buildNavItem(
              icon: Icons.bar_chart,
              label: 'Análise de dados',
              isSelected: false,
              onTap: () {
                context.go('/analise');
              },
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Cadastros',
              isSelected: false,
              onTap: () {
                context.go('/cadastros');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método para tratar o logout usando o AuthController
  Future<void> _handleLogout(
      BuildContext context, AuthController authController) async {
    try {
      // Mostrar diálogo de confirmação
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sair do aplicativo'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        ),
      );

      if (shouldLogout != true) {
        return;
      }

      // Mostrar indicador de progresso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Usar o caso de uso através do controller
      await authController.logout();

      // Navegar para a tela de login
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Fechar diálogo de progresso se estiver aberto
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer logout: $e')),
        );
      }
    }
  }

  // Widget auxiliar para criar itens de navegação
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
