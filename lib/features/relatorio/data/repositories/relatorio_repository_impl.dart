import '../../domain/entities/relatorio.dart';
import '../../domain/repositories/relatorio_repository.dart';
import '../datasources/relatorio_datasource.dart';
import '../models/relatorio_model.dart';

class RelatorioRepositoryImpl implements RelatorioRepository {
  final RelatorioDataSource dataSource;

  RelatorioRepositoryImpl({required this.dataSource});

  @override
  Stream<List<Relatorio>> getRelatoriosByObraId(String obraId) {
    return dataSource.getRelatoriosByObraId(obraId);
  }

  @override
  Future<String> saveRelatorio(String obraId, Relatorio relatorio) async {
    // Converter a entidade em modelo se necessário
    final relatorioModel = relatorio is RelatorioModel
        ? relatorio
        : RelatorioModel.fromRelatorio(relatorio);

    return await dataSource.saveRelatorio(obraId, relatorioModel);
  }

  @override
  Future<void> updateRelatorio(String obraId, Relatorio relatorio) async {
    // Converter a entidade em modelo
    final relatorioModel = relatorio is RelatorioModel
        ? relatorio
        : RelatorioModel.fromRelatorio(relatorio);

    await dataSource.updateRelatorio(obraId, relatorioModel);
  }

  @override
  Future<void> deleteRelatorio(String obraId, String relatorioId) async {
    await dataSource.deleteRelatorio(obraId, relatorioId);
  }

  @override
  Future<Relatorio?> getRelatorioById(String obraId, String relatorioId) {
    return dataSource.getRelatorioById(obraId, relatorioId);
  }
}
