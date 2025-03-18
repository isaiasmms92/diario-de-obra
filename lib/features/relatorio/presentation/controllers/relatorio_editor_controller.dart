// Em /presentation/controllers/edit_relatorio_controller.dart

import 'package:flutter/material.dart';

import '../../../obra/domain/entities/obra.dart';
import '../../../obra/domain/usecases/get_obra_by_id_usecase.dart';
import '../../domain/entities/relatorio.dart';
import '../../domain/usecases/get_relatorio_by_id_usecase.dart';
import '../../domain/usecases/update_relatorio_usecase.dart';

class EditRelatorioController extends ChangeNotifier {
  final GetRelatorioByIdUseCase getRelatorioByIdUseCase;
  final UpdateRelatorioUseCase updateRelatorioUseCase;
  final GetObraByIdUseCase getObraByIdUseCase;

  Relatorio? _relatorio;
  Obra? _obra;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Relatorio? get relatorio => _relatorio;
  Obra? get obra => _obra;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EditRelatorioController({
    required this.getRelatorioByIdUseCase,
    required this.updateRelatorioUseCase,
    required this.getObraByIdUseCase,
  });

  Future<void> loadData(String obraId, String relatorioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carregando obra e relatório
      final obraFuture = getObraByIdUseCase(obraId);
      final relatorioFuture = getRelatorioByIdUseCase(obraId, relatorioId);

      // Aguardando resultados
      final results = await Future.wait([obraFuture, relatorioFuture]);

      _obra = results[0] as Obra?;
      _relatorio = results[1] as Relatorio?;

      if (_obra == null || _relatorio == null) {
        _errorMessage = "Não foi possível carregar os dados";
      }
    } catch (e) {
      _errorMessage = "Erro ao carregar dados: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRelatorio(Relatorio updatedRelatorio) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateRelatorioUseCase(_obra!.id!, updatedRelatorio);
      _relatorio = updatedRelatorio;
      return true;
    } catch (e) {
      _errorMessage = "Erro ao salvar relatório: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para atualizar os diversos campos do relatório
  void updateCondicaoClimatica(/* parâmetros relevantes */) {
    // Atualize os dados do _relatorio
    notifyListeners();
  }

  Future<void> refreshMaoDeObra(String obraId, String relatorioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Utiliza o caso de uso existente para buscar o relatório atualizado
      final updatedRelatorio =
          await getRelatorioByIdUseCase(obraId, relatorioId);

      if (updatedRelatorio != null) {
        _relatorio = updatedRelatorio;
      } else {
        _errorMessage = "Não foi possível atualizar os dados de mão de obra";
      }
    } catch (e) {
      _errorMessage = "Erro ao atualizar mão de obra: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEquipamentos(String obraId, String relatorioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Utiliza o caso de uso existente para buscar o relatório atualizado
      final updatedRelatorio =
          await getRelatorioByIdUseCase(obraId, relatorioId);

      if (updatedRelatorio != null) {
        _relatorio = updatedRelatorio;
      } else {
        _errorMessage = "Não foi possível atualizar os dados de equipamentos";
      }
    } catch (e) {
      _errorMessage = "Erro ao atualizar equipamentos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAtividades(String obraId, String relatorioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Utiliza o caso de uso existente para buscar o relatório atualizado
      final updatedRelatorio =
          await getRelatorioByIdUseCase(obraId, relatorioId);

      if (updatedRelatorio != null) {
        _relatorio = updatedRelatorio;
      } else {
        _errorMessage = "Não foi possível atualizar os dados de atividades";
      }
    } catch (e) {
      _errorMessage = "Erro ao atualizar atividades: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
