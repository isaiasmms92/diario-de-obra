import '../entities/obra.dart';
import '../repositories/obra_repository.dart';

class UpdateObraUseCase {
  final ObraRepository repository;

  UpdateObraUseCase(this.repository);

  Future<void> call(Obra obra) async {
    await repository.updateObra(obra);
  }
}
