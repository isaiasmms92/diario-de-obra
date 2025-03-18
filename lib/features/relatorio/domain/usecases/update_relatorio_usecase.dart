import '../entities/relatorio.dart';
import '../repositories/relatorio_repository.dart';

class UpdateRelatorioUseCase {
  final RelatorioRepository repository;

  UpdateRelatorioUseCase(this.repository);

  Future<void> call(String obraId, Relatorio relatorio) {
    return repository.updateRelatorio(obraId, relatorio);
  }
}
