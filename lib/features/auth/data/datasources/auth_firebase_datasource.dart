import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginWithGoogle();
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthFirebaseDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthFirebaseDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login falhou: usuário não encontrado');
      }

      return UserModel.fromFirebase(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado para este email');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'user-disabled':
          throw Exception('Este usuário foi desativado');
        case 'too-many-requests':
          throw Exception('Muitas tentativas. Tente novamente mais tarde');
        default:
          throw Exception('Erro ao fazer login: ${e.message}');
      }
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      // Iniciar processo de login do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login do Google cancelado pelo usuário');
      }

      // Obter detalhes de autenticação do Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Criar credencial Firebase com tokens Google
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Fazer login no Firebase com a credencial do Google
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login do Google falhou: usuário não encontrado');
      }

      return UserModel.fromFirebase(user);
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String nome) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Registro falhou: usuário não criado');
      }

      // Atualizar o nome de exibição do usuário
      await user.updateDisplayName(nome);

      // Recarregar o usuário para obter as informações atualizadas
      await user.reload();

      // Buscar usuário atualizado
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw Exception('Erro ao buscar usuário após atualização');
      }

      return UserModel.fromFirebase(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este email já está sendo usado');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'weak-password':
          throw Exception('A senha é muito fraca');
        default:
          throw Exception('Erro ao registrar: ${e.message}');
      }
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebase(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFirebase(firebaseUser);
    });
  }
}
