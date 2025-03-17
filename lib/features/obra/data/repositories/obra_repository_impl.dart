import '../../domain/entities/obra.dart';
import '../../domain/repositories/obra_repository.dart';
import '../datasources/obra_datasource.dart';
import '../models/obra_model.dart';

class ObraRepositoryImpl implements ObraRepository {
  final ObraDataSource dataSource;

  ObraRepositoryImpl({required this.dataSource});

  @override
  Future<List<Obra>> getObras() async {
    try {
      final result = await dataSource.getObras();
      // O modelo já estende a entidade, então podemos retornar diretamente
      return result.map((model) => ObraModel.calcularPrazos(model)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar obras: $e');
    }
  }

  @override
  Future<Obra?> getObraById(String id) async {
    try {
      final result = await dataSource.getObraById(id);
      if (result == null) {
        return null;
      }
      return ObraModel.calcularPrazos(result);
    } catch (e) {
      throw Exception('Falha ao buscar obra: $e');
    }
  }

  @override
  Future<String> saveObra(Obra obra) async {
    try {
      // Converter a entidade em modelo se necessário
      final obraModel = obra is ObraModel
          ? obra
          : ObraModel(
              id: obra.id,
              nome: obra.nome,
              status: obra.status,
              numeroContrato: obra.numeroContrato,
              responsavel: obra.responsavel,
              contratante: obra.contratante,
              dataInicio: obra.dataInicio,
              previsaoTermino: obra.previsaoTermino,
              prazoContratual: obra.prazoContratual,
              prazoDecorrido: obra.prazoDecorrido,
              prazoVencer: obra.prazoVencer,
              endereco: obra.endereco,
              observacao: obra.observacao,
              fotoUrl: obra.fotoUrl,
              relatoriosCount: obra.relatoriosCount,
            );

      // Calcula os prazos antes de salvar
      final obraComPrazos = ObraModel.calcularPrazos(obraModel);

      return await dataSource.saveObra(obraComPrazos);
    } catch (e) {
      throw Exception('Falha ao salvar obra: $e');
    }
  }

  @override
  Future<void> updateObra(Obra obra) async {
    try {
      // Converter a entidade em modelo
      final obraModel = obra is ObraModel
          ? obra
          : ObraModel(
              id: obra.id,
              nome: obra.nome,
              status: obra.status,
              numeroContrato: obra.numeroContrato,
              responsavel: obra.responsavel,
              contratante: obra.contratante,
              dataInicio: obra.dataInicio,
              previsaoTermino: obra.previsaoTermino,
              prazoContratual: obra.prazoContratual,
              prazoDecorrido: obra.prazoDecorrido,
              prazoVencer: obra.prazoVencer,
              endereco: obra.endereco,
              observacao: obra.observacao,
              fotoUrl: obra.fotoUrl,
              relatoriosCount: obra.relatoriosCount,
            );

      // Calcula os prazos antes de atualizar
      final obraComPrazos = ObraModel.calcularPrazos(obraModel);

      await dataSource.updateObra(obraComPrazos);
    } catch (e) {
      throw Exception('Falha ao atualizar obra: $e');
    }
  }

  @override
  Future<void> deleteObra(String id) async {
    try {
      await dataSource.deleteObra(id);
    } catch (e) {
      throw Exception('Falha ao excluir obra: $e');
    }
  }
}
