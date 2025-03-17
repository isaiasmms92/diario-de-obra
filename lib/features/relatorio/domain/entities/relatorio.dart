class Relatorio {
  final String? id;
  final String obraId;
  final DateTime data;
  final List<String> sections;
  final bool copyLast;
  final DateTime? createdAt;
  final Map<String, List<dynamic>> content;
  final String status;

  static const List<String> allSections = [
    'Condição climática',
    'Índice pluviométrico',
    'Mão de obra',
    'Equipamentos',
    'Atividades',
    'Ocorrências',
    'Comentários',
    'Fotos',
    'Vídeos',
    'Anexos',
  ];

  const Relatorio({
    this.id,
    required this.obraId,
    required this.data,
    required this.sections,
    required this.copyLast,
    this.createdAt,
    required this.content,
    this.status = 'Preenchendo',
  });
}
