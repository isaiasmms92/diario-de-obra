import '../repositories/obra_repository.dart';

class DeleteObraUseCase {
  final ObraRepository repository;

  DeleteObraUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteObra(id);
  }
}
