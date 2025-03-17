// features/obra/data/models/obra_model.dart
import 'package:intl/intl.dart';
import '../../domain/entities/obra.dart';

class ObraModel extends Obra {
  ObraModel({
    super.id,
    super.nome,
    super.status,
    super.numeroContrato,
    super.responsavel,
    super.contratante,
    super.dataInicio,
    super.previsaoTermino,
    super.prazoContratual,
    super.prazoDecorrido,
    super.prazoVencer,
    super.endereco,
    super.observacao,
    super.fotoUrl,
    super.relatoriosCount,
  });

  // Criar modelo a partir do mapa (vindo do Firestore)
  factory ObraModel.fromMap(Map<String, dynamic> map, String docId) {
    return ObraModel(
      id: docId,
      nome: map['nome'],
      status: map['status'],
      numeroContrato: map['numeroContrato'],
      responsavel: map['responsavel'],
      contratante: map['contratante'],
      dataInicio: map['dataInicio'],
      previsaoTermino: map['previsaoTermino'],
      prazoContratual: map['prazoContratual'],
      prazoDecorrido: map['prazoDecorrido'],
      prazoVencer: map['prazoVencer'],
      endereco: map['endereco'],
      observacao: map['observacao'],
      fotoUrl: map['fotoUrl'],
      relatoriosCount: map['relatoriosCount'],
    );
  }

  // Converter modelo para mapa (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'status': status,
      'numeroContrato': numeroContrato,
      'responsavel': responsavel,
      'contratante': contratante,
      'dataInicio': dataInicio,
      'previsaoTermino': previsaoTermino,
      'prazoContratual': prazoContratual,
      'prazoDecorrido': prazoDecorrido,
      'prazoVencer': prazoVencer,
      'endereco': endereco,
      'observacao': observacao,
      'fotoUrl': fotoUrl,
      'relatoriosCount': relatoriosCount,
    };
  }

  // Método estático para calcular os prazos
  static ObraModel calcularPrazos(ObraModel obra) {
    if (obra.dataInicio == null || obra.dataInicio!.isEmpty) {
      return obra;
    }

    try {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final DateTime dataInicio = formatter.parse(obra.dataInicio!);
      final DateTime hoje = DateTime.now();

      // Calcular prazo decorrido
      final int prazoDecorridoDias = hoje.difference(dataInicio).inDays;

      // Definir prazo contratual padrão se não estiver definido
      final int prazoContratualDias = obra.prazoContratual ?? 0;

      // Calcular prazo a vencer
      final int prazoVencerDias = prazoContratualDias - prazoDecorridoDias;

      // Calcular previsão de término se não estiver definida
      String? previsaoTermino = obra.previsaoTermino;
      if (previsaoTermino == null || previsaoTermino.isEmpty) {
        final DateTime dataPrevisaoTermino =
            dataInicio.add(Duration(days: prazoContratualDias));
        previsaoTermino = formatter.format(dataPrevisaoTermino);
      }

      return ObraModel(
        id: obra.id,
        nome: obra.nome,
        status: obra.status,
        numeroContrato: obra.numeroContrato,
        responsavel: obra.responsavel,
        contratante: obra.contratante,
        dataInicio: obra.dataInicio,
        previsaoTermino: previsaoTermino,
        prazoContratual: prazoContratualDias,
        prazoDecorrido: prazoDecorridoDias >= 0 ? prazoDecorridoDias : 0,
        prazoVencer: prazoVencerDias >= 0 ? prazoVencerDias : 0,
        endereco: obra.endereco,
        observacao: obra.observacao,
        fotoUrl: obra.fotoUrl,
        relatoriosCount: obra.relatoriosCount,
      );
    } catch (e) {
      print('Erro ao calcular prazos: $e');
      return obra;
    }
  }

  // Criar uma cópia do modelo com valores alterados
  ObraModel copyWith({
    String? id,
    String? nome,
    String? status,
    String? numeroContrato,
    String? responsavel,
    String? contratante,
    String? dataInicio,
    String? previsaoTermino,
    int? prazoContratual,
    int? prazoDecorrido,
    int? prazoVencer,
    String? endereco,
    String? observacao,
    String? fotoUrl,
    int? relatoriosCount,
  }) {
    return ObraModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      status: status ?? this.status,
      numeroContrato: numeroContrato ?? this.numeroContrato,
      responsavel: responsavel ?? this.responsavel,
      contratante: contratante ?? this.contratante,
      dataInicio: dataInicio ?? this.dataInicio,
      previsaoTermino: previsaoTermino ?? this.previsaoTermino,
      prazoContratual: prazoContratual ?? this.prazoContratual,
      prazoDecorrido: prazoDecorrido ?? this.prazoDecorrido,
      prazoVencer: prazoVencer ?? this.prazoVencer,
      endereco: endereco ?? this.endereco,
      observacao: observacao ?? this.observacao,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      relatoriosCount: relatoriosCount ?? this.relatoriosCount,
    );
  }
}
