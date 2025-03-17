import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/auth_state_changes_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthController with ChangeNotifier {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthStateChangesUseCase authStateChangesUseCase;
  final RegisterUseCase registerUseCase; // Novo caso de uso

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _authStateSubscription;

  AuthController({
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.logoutUseCase,
    required this.registerUseCase, // Novo parâmetro
    required this.getCurrentUserUseCase,
    required this.authStateChangesUseCase,
  }) {
    _initAuthState();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _initAuthState() {
    _authStateSubscription = authStateChangesUseCase().listen((user) {
      _currentUser = user;
      notifyListeners();
    });

    // Também tentamos obter o usuário atual imediatamente
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await getCurrentUserUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await loginWithEmailUseCase(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await loginWithGoogleUseCase();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await logoutUseCase();
      // O _currentUser será atualizado pelo listener do authStateChanges
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Novo método para registro
  Future<bool> register(String email, String password, String nome) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await registerUseCase(email, password, nome);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
