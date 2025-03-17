import 'dart:async';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<User> loginWithEmail(String email, String password) async {
    try {
      return await dataSource.loginWithEmail(email, password);
    } catch (e) {
      throw Exception('Falha ao fazer login com email: $e');
    }
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      return await dataSource.loginWithGoogle();
    } catch (e) {
      throw Exception('Falha ao fazer login com Google: $e');
    }
  }

  @override
  Future<User> register(String email, String password, String nome) async {
    try {
      return await dataSource.register(email, password, nome);
    } catch (e) {
      throw Exception('Falha ao registrar usuário: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.logout();
    } catch (e) {
      throw Exception('Falha ao fazer logout: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } catch (e) {
      throw Exception('Falha ao obter usuário atual: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return dataSource.authStateChanges;
  }
}
