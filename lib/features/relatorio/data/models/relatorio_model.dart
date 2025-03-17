// features/relatorio/data/models/relatorio_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/relatorio.dart';

class RelatorioModel extends Relatorio {
  RelatorioModel({
    super.id,
    required super.obraId,
    required super.data,
    required super.sections,
    required super.copyLast,
    super.createdAt,
    required super.content,
    super.status,
  });

  // Converte o objeto RelatorioModel para um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'obraId': obraId,
      'data': data.toIso8601String(),
      'sections': sections,
      'copyLast': copyLast,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'content': content,
      'status': status,
    };
  }

  // Cria um objeto RelatorioModel a partir de um Map vindo do Firestore
  factory RelatorioModel.fromMap(Map<String, dynamic> map, String id) {
    // Convertendo o Timestamp do Firestore para DateTime se necessário
    DateTime? createdAtDate;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        createdAtDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        createdAtDate = DateTime.parse(map['createdAt']);
      }
    }

    // Convertendo o conteúdo do Firestore para o formato Map<String, List<dynamic>>
    Map<String, List<dynamic>> contentMap = {};
    if (map['content'] != null && map['content'] is Map) {
      map['content'].forEach((key, value) {
        if (value is List) {
          contentMap[key] = List<dynamic>.from(value);
        } else {
          contentMap[key] = [];
        }
      });
    } else {
      // Se o conteúdo não for um Map, inicializa todas as seções como listas vazias
      contentMap = Map.fromIterable(
        Relatorio.allSections,
        key: (section) => section,
        value: (section) => <dynamic>[],
      );
    }

    return RelatorioModel(
      id: id,
      obraId: map['obraId'] ?? '',
      data: DateTime.parse(map['data'] ?? DateTime.now().toIso8601String()),
      sections: List<String>.from(map['sections'] ?? Relatorio.allSections),
      copyLast: map['copyLast'] ?? false,
      createdAt: createdAtDate,
      content: contentMap,
      status: map['status'] ?? 'Preenchendo',
    );
  }

  // Método para criar uma cópia do modelo com novos valores
  RelatorioModel copyWith({
    String? id,
    String? obraId,
    DateTime? data,
    List<String>? sections,
    bool? copyLast,
    DateTime? createdAt,
    Map<String, List<dynamic>>? content,
    String? status,
  }) {
    return RelatorioModel(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      data: data ?? this.data,
      sections: sections ?? this.sections,
      copyLast: copyLast ?? this.copyLast,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      status: status ?? this.status,
    );
  }

  // Método para converter uma entidade Relatorio em um RelatorioModel
  factory RelatorioModel.fromRelatorio(Relatorio relatorio) {
    return RelatorioModel(
      id: relatorio.id,
      obraId: relatorio.obraId,
      data: relatorio.data,
      sections: relatorio.sections,
      copyLast: relatorio.copyLast,
      createdAt: relatorio.createdAt,
      content: relatorio.content,
      status: relatorio.status,
    );
  }
}
