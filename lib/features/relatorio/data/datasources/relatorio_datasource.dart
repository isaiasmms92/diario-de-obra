import '../models/relatorio_model.dart';

abstract class RelatorioDataSource {
  Stream<List<RelatorioModel>> getRelatoriosByObraId(String obraId);
  Future<String> saveRelatorio(String obraId, RelatorioModel relatorio);
  Future<void> updateRelatorio(String obraId, RelatorioModel relatorio);
  Future<void> deleteRelatorio(String obraId, String relatorioId);
  Future<RelatorioModel?> getRelatorioById(String obraId, String relatorioId);
}
