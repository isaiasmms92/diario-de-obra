import '../entities/relatorio.dart';
import '../repositories/relatorio_repository.dart';

class GetRelatorioByIdUseCase {
  final RelatorioRepository repository;

  GetRelatorioByIdUseCase(this.repository);

  Future<Relatorio?> call(String obraId, String relatorioId) async {
    // Você precisará adicionar este método ao repository
    // Ou usar uma combinação de outros métodos para obter o relatório específico
    return await repository.getRelatorioById(obraId, relatorioId);
  }
}
