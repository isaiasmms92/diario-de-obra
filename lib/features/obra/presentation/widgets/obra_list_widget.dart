// features/obra/presentation/widgets/obra_list_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/obra.dart';

class ObraListWidget extends StatelessWidget {
  final List<Obra> obras;
  final double bottomPadding;

  const ObraListWidget({
    super.key,
    required this.obras,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: obras.length,
      itemBuilder: (context, index) {
        final obra = obras[index];
        return _buildObraCard(context, obra);
      },
    );
  }

  Widget _buildObraCard(BuildContext context, Obra obra) {
    final statusColor = _getStatusColor(obra.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes da obra
          context.go('/obra/${obra.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      obra.nome ?? 'Sem nome',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      obra.status ?? 'Indefinido',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (obra.contratante != null && obra.contratante!.isNotEmpty)
                Text('Contratante: ${obra.contratante}'),
              if (obra.responsavel != null && obra.responsavel!.isNotEmpty)
                Text('Responsável: ${obra.responsavel}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    obra.dataInicio ?? 'Data não definida',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _getPrazoColor(obra.prazoVencer),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    obra.prazoVencer != null
                        ? '${obra.prazoVencer} dias restantes'
                        : 'Prazo não definido',
                    style: TextStyle(
                      color: _getPrazoColor(obra.prazoVencer),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'em andamento':
        return Colors.blue;
      case 'concluída':
        return Colors.green;
      case 'atrasada':
        return Colors.red;
      case 'paralisada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPrazoColor(int? prazo) {
    if (prazo == null) return Colors.grey;

    if (prazo <= 0) {
      return Colors.red;
    } else if (prazo <= 15) {
      return Colors.orange;
    } else if (prazo <= 30) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}
