// features/obra/domain/entities/obra.dart
class Obra {
  final String? id;
  final String? nome;
  final String? status;
  final String? numeroContrato;
  final String? responsavel;
  final String? contratante;
  final String? dataInicio;
  final String? previsaoTermino;
  final int? prazoContratual;
  final int? prazoDecorrido;
  final int? prazoVencer;
  final String? endereco;
  final String? observacao;
  final String? fotoUrl;
  final int? relatoriosCount;

  const Obra({
    this.id,
    this.nome,
    this.status,
    this.numeroContrato,
    this.responsavel,
    this.contratante,
    this.dataInicio,
    this.previsaoTermino,
    this.prazoContratual,
    this.prazoDecorrido,
    this.prazoVencer,
    this.endereco,
    this.observacao,
    this.fotoUrl,
    this.relatoriosCount,
  });

  // Métodos de domínio que não dependem de nada externo
  String formatarPrazo(int? dias) {
    return dias != null && dias >= 0 ? '$dias dias' : '0 dias';
  }
}
