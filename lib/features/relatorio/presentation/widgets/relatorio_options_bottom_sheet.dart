import 'package:flutter/material.dart';

class RelatorioOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  const RelatorioOptionsBottomSheet({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onPrint,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que deseja:',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildOptionTile(context, 'Visualizar', onView),
          _buildOptionTile(context, 'Editar', onEdit),
          _buildOptionTile(context, 'Imprimir (PDF)', onPrint),
          _buildOptionTile(context, 'Excluir', onDelete),
          _buildOptionTile(context, 'Cancelar', () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      minLeadingWidth: 0,
    );
  }
}
