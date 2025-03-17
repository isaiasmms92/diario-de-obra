// features/obra/presentation/controllers/obra_controller.dart
import 'package:flutter/material.dart';
import '../../domain/entities/obra.dart';
import '../../domain/usecases/get_obras_usecase.dart';
import '../../domain/usecases/save_obra_usecase.dart';
import '../../domain/usecases/update_obra_usecase.dart';
import '../../domain/usecases/delete_obra_usecase.dart';

class ObraController with ChangeNotifier {
  final GetObrasUseCase getObrasUseCase;
  final SaveObraUseCase saveObraUseCase;
  final UpdateObraUseCase updateObraUseCase;
  final DeleteObraUseCase deleteObraUseCase;

  ObraController({
    required this.getObrasUseCase,
    required this.saveObraUseCase,
    required this.updateObraUseCase,
    required this.deleteObraUseCase,
  });

  List<Obra> _obras = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Obra> get obras => _obras;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> fetchObras() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _obras = await getObrasUseCase();
    } catch (e) {
      _errorMessage = "Não foi possível carregar as obras: ${e.toString()}";
      _obras = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveObra(Obra obra) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await saveObraUseCase(obra);
      await fetchObras(); // Recarrega a lista após salvar
      return id;
    } catch (e) {
      _errorMessage = "Não foi possível salvar a obra: ${e.toString()}";
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateObra(Obra obra) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateObraUseCase(obra);
      await fetchObras(); // Recarrega a lista após atualizar
      return true;
    } catch (e) {
      _errorMessage = "Não foi possível atualizar a obra: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteObra(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await deleteObraUseCase(id);
      await fetchObras(); // Recarrega a lista após excluir
      return true;
    } catch (e) {
      _errorMessage = "Não foi possível excluir a obra: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}
