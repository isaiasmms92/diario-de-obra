import '../models/obra_model.dart';

abstract class ObraDataSource {
  Future<List<ObraModel>> getObras();
  Future<ObraModel?> getObraById(String id);
  Future<String> saveObra(ObraModel obra);
  Future<void> updateObra(ObraModel obra);
  Future<void> deleteObra(String id);
}
