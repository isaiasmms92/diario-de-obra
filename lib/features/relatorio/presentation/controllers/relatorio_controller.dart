import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/relatorio.dart';
import '../../domain/usecases/get_relatorios_by_obra_id_usecase.dart';
import '../../domain/usecases/delete_relatorio_usecase.dart';
import '../../../obra/domain/entities/obra.dart';
import '../../../obra/domain/usecases/get_obra_by_id_usecase.dart';

class RelatorioController extends ChangeNotifier {
  final GetObraByIdUseCase getObraByIdUseCase;
  final GetRelatoriosByObraIdUseCase getRelatoriosByObraIdUseCase;
  final DeleteRelatorioUseCase deleteRelatorioUseCase;

  RelatorioController({
    required this.getObraByIdUseCase,
    required this.getRelatoriosByObraIdUseCase,
    required this.deleteRelatorioUseCase,
  });

  Obra? _obra;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _relatoriosSubscription;
  List<Relatorio> _relatorios = [];

  Obra? get obra => _obra;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Relatorio> get relatorios => _relatorios;

  void initialize({Obra? obra, String? obraId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (obra != null) {
        _obra = obra;
        _loadRelatorios(obra.id!);
      } else if (obraId != null) {
        // Carrega a obra pelo ID primeiro
        final obraCarregada = await getObraByIdUseCase(obraId);
        if (obraCarregada != null) {
          _obra = obraCarregada;
          _loadRelatorios(obraId);
        } else {
          _errorMessage = "Não foi possível encontrar a obra";
        }
      } else {
        _errorMessage = "Nenhuma obra especificada";
      }
    } catch (e) {
      _errorMessage = "Erro ao carregar dados: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadObra(String obraId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final obraCarregada = await getObraByIdUseCase(obraId);

      if (obraCarregada == null) {
        _errorMessage = 'Obra não encontrada';
      } else {
        _obra = obraCarregada;
        _loadRelatorios(obraId);
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar a obra: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Novo método para carregar uma obra pelo ID
  Future<Obra?> loadObra(String obraId) async {
    try {
      final obraCarregada = await getObraByIdUseCase(obraId);
      if (obraCarregada == null) {
        throw Exception('Obra não encontrada');
      }
      return obraCarregada;
    } catch (e) {
      _errorMessage = 'Erro ao carregar obra: ${e.toString()}';
      notifyListeners();
      throw e; // Propagar o erro para permitir tratamento na UI
    }
  }

  void _loadRelatorios(String obraId) {
    // Cancela a inscrição anterior, se houver
    _relatoriosSubscription?.cancel();

    // Inscreve no stream de relatórios
    _relatoriosSubscription =
        getRelatoriosByObraIdUseCase(obraId).listen((relatorios) {
      _relatorios = relatorios;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Erro ao carregar relatórios: $error';
      notifyListeners();
    });
  }

  Future<void> deleteRelatorio(String relatorioId) async {
    if (_obra?.id == null) return;

    try {
      await deleteRelatorioUseCase(_obra!.id!, relatorioId);
      // O stream já atualizará a lista automaticamente
    } catch (e) {
      _errorMessage = 'Erro ao excluir relatório: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _relatoriosSubscription?.cancel();
    super.dispose();
  }
}
