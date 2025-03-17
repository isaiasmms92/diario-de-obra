import '../entities/obra.dart';
import '../repositories/obra_repository.dart';

class GetObraByIdUseCase {
  final ObraRepository repository;

  GetObraByIdUseCase(this.repository);

  Future<Obra?> call(String id) async {
    return await repository.getObraById(id);
  }
}
