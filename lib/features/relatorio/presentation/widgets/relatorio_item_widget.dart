import 'package:flutter/material.dart';
import '../../domain/entities/relatorio.dart';

class RelatorioItemWidget extends StatelessWidget {
  final Relatorio relatorio;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const RelatorioItemWidget({
    Key? key,
    required this.relatorio,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        '${relatorio.data.day.toString().padLeft(2, '0')}/${relatorio.data.month.toString().padLeft(2, '0')}/${relatorio.data.year}';

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: Icon(Icons.description, color: Colors.grey, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataFormatada,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Relatório Diário de Obra (RDO)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(100, 36),
                ),
                child: const Text('Preenchendo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
