// features/obra/presentation/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.engineering,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma obra cadastrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão abaixo para adicionar sua primeira obra',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/add-obra');
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Obra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
