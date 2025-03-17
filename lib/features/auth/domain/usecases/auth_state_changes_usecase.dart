import 'dart:async';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthStateChangesUseCase {
  final AuthRepository repository;

  AuthStateChangesUseCase(this.repository);

  Stream<User?> call() {
    return repository.authStateChanges;
  }
}
