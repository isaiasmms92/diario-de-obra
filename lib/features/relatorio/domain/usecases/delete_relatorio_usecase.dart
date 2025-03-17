import '../repositories/relatorio_repository.dart';

class DeleteRelatorioUseCase {
  final RelatorioRepository repository;

  DeleteRelatorioUseCase(this.repository);

  Future<void> call(String obraId, String relatorioId) async {
    await repository.deleteRelatorio(obraId, relatorioId);
  }
}
