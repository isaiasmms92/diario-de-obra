import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String email, String password, String nome) async {
    return await repository.register(email, password, nome);
  }
}
