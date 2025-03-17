import '../entities/obra.dart';
import '../repositories/obra_repository.dart';

class GetObrasUseCase {
  final ObraRepository repository;

  GetObrasUseCase(this.repository);

  Future<List<Obra>> call() async {
    return await repository.getObras();
  }
}
