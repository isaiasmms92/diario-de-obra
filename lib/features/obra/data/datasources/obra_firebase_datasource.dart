// features/obra/data/datasources/obra_firebase_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/obra_model.dart';
import './obra_datasource.dart';

class ObraFirebaseDataSource implements ObraDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'obras';

  ObraFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ObraModel>> getObras() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => ObraModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ObraModel?> getObraById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return ObraModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<String> saveObra(ObraModel obra) async {
    final docRef = _firestore.collection(_collection).doc();
    await docRef.set(obra.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateObra(ObraModel obra) async {
    if (obra.id == null) {
      throw Exception('Não é possível atualizar uma obra sem ID');
    }
    await _firestore.collection(_collection).doc(obra.id).update(obra.toMap());
  }

  @override
  Future<void> deleteObra(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
