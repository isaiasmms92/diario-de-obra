// features/obra/domain/repositories/obra_repository.dart
import '../entities/obra.dart';

abstract class ObraRepository {
  Future<List<Obra>> getObras();
  Future<Obra?> getObraById(String id);
  Future<String> saveObra(Obra obra);
  Future<void> updateObra(Obra obra);
  Future<void> deleteObra(String id);
}
