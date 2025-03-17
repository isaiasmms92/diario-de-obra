import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    String? name,
    String? photoUrl,
  }) : super(
          nome: name,
          fotoUrl: photoUrl,
        );

  factory UserModel.fromFirebase(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': nome,
      'photoUrl': fotoUrl,
    };
  }
}
