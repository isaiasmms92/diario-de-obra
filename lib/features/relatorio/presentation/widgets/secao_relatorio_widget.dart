import 'package:flutter/material.dart';

class SecaoRelatorioWidget extends StatelessWidget {
  final String titulo;
  final List<dynamic> conteudo;

  const SecaoRelatorioWidget({
    Key? key,
    required this.titulo,
    required this.conteudo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 16, color: Colors.orange),
          ),
          if (conteudo.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Aqui você pode adicionar a lógica para exibir o conteúdo de cada seção
            // dependendo do tipo de conteúdo
            ...conteudo.map((item) {
              if (item is Map<String, dynamic>) {
                return ListTile(
                  title: Text(item['title'] ?? 'Sem título'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['description'] != null)
                        Text(item['description']),
                      if (item['time'] != null) Text('Tempo: ${item['time']}'),
                      if (item['progress'] != null)
                        Text('Progresso: ${item['progress']}'),
                    ],
                  ),
                  leading: item['imageUrl'] != null
                      ? Image.network(
                          item['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported,
                                size: 50);
                          },
                        )
                      : null,
                );
              }
              return ListTile(
                title: Text(item.toString()),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
