import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Retorna o usuário atual (se autenticado)
  User? get currentUser => _auth.currentUser;

  // Login com e-mail e senha
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // Registro com e-mail e senha
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      // Inicia o processo de login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login com Google cancelado pelo usuário');
      }

      // Obtém as credenciais do Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login no Firebase com as credenciais do Google
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${_handleAuthError(e)}');
    }
  }

  // Manipula erros de autenticação para mensagens amigáveis
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuário não encontrado. Verifique o e-mail.';
        case 'wrong-password':
          return 'Senha incorreta. Tente novamente.';
        case 'email-already-in-use':
          return 'Este e-mail já está em uso.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'weak-password':
          return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
        case 'operation-not-allowed':
          return 'Operação não permitida. Contate o suporte.';
        default:
          return 'Ocorreu um erro. Tente novamente.';
      }
    }
    return 'Ocorreu um erro inesperado: $error';
  }

  // Verifica se o usuário está autenticado
  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }
}
