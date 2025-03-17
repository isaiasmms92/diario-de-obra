import '../entities/obra.dart';
import '../repositories/obra_repository.dart';

class SaveObraUseCase {
  final ObraRepository repository;

  SaveObraUseCase(this.repository);

  Future<String> call(Obra obra) async {
    return await repository.saveObra(obra);
  }
}
