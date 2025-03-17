import '../entities/relatorio.dart';
import '../repositories/relatorio_repository.dart';

class GetRelatoriosByObraIdUseCase {
  final RelatorioRepository repository;

  GetRelatoriosByObraIdUseCase(this.repository);

  Stream<List<Relatorio>> call(String obraId) {
    return repository.getRelatoriosByObraId(obraId);
  }
}
