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
    'Condicao Climática',
    'Índice Pluviométrico',
    'Mão de Obra',
    'Equipamentos',
    'Atividades',
    'Ocorrências',
    'Comentários',
    'Fotos',
    'Videos',
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

  // Método copyWith para criar uma cópia com algumas propriedades modificadas
  Relatorio copyWith({
    String? id,
    String? obraId,
    DateTime? data,
    List<String>? sections,
    bool? copyLast,
    DateTime? createdAt,
    Map<String, List<dynamic>>? content,
    String? status,
  }) {
    return Relatorio(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      data: data ?? this.data,
      sections: sections ?? List<String>.from(this.sections),
      copyLast: copyLast ?? this.copyLast,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? Map<String, List<dynamic>>.from(this.content),
      status: status ?? this.status,
    );
  }
}
