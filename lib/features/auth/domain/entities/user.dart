class User {
  final String id;
  final String email;
  final String? nome;
  final String? fotoUrl;

  User({
    required this.id,
    required this.email,
    this.nome,
    this.fotoUrl,
  });
}
