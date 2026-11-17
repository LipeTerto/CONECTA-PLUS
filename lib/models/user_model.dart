/// Perfil do usuário (tabela `profiles`).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  /// Converte o Map devolvido pelo Supabase em um objeto Dart.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }
}