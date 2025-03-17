import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/relatorio_model.dart';
import './relatorio_datasource.dart';

class RelatorioFirebaseDataSource implements RelatorioDataSource {
  final FirebaseFirestore _firestore;

  RelatorioFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<RelatorioModel>> getRelatoriosByObraId(String obraId) {
    return _firestore
        .collection('obras')
        .doc(obraId)
        .collection('relatorios')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RelatorioModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<String> saveRelatorio(String obraId, RelatorioModel relatorio) async {
    // Incrementa o contador de relatórios na obra
    await _firestore.collection('obras').doc(obraId).update({
      'relatoriosCount': FieldValue.increment(1),
    });

    final docRef = _firestore
        .collection('obras')
        .doc(obraId)
        .collection('relatorios')
        .doc();

    await docRef.set(relatorio.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateRelatorio(String obraId, RelatorioModel relatorio) async {
    if (relatorio.id == null) {
      throw Exception('Não é possível atualizar um relatório sem ID');
    }

    await _firestore
        .collection('obras')
        .doc(obraId)
        .collection('relatorios')
        .doc(relatorio.id)
        .update(relatorio.toMap());
  }

  @override
  Future<void> deleteRelatorio(String obraId, String relatorioId) async {
    // Decrementa o contador de relatórios na obra
    await _firestore.collection('obras').doc(obraId).update({
      'relatoriosCount': FieldValue.increment(-1),
    });

    await _firestore
        .collection('obras')
        .doc(obraId)
        .collection('relatorios')
        .doc(relatorioId)
        .delete();
  }
}
