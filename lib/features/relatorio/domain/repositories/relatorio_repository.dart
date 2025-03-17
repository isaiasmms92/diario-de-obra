import '../entities/relatorio.dart';

abstract class RelatorioRepository {
  Stream<List<Relatorio>> getRelatoriosByObraId(String obraId);
  Future<String> saveRelatorio(String obraId, Relatorio relatorio);
  Future<void> updateRelatorio(String obraId, Relatorio relatorio);
  Future<void> deleteRelatorio(String obraId, String relatorioId);
}
