/// Instituição / espaço de acolhimento (tabela `institutions`).
class InstitutionModel {
  const InstitutionModel({
    this.id,
    this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.contactInfo,
    this.website,
    this.createdAt,
    this.isCancelled = false,
  });

  final String? id; // null até ser salva
  final String? userId; // autor (preenchido pelo banco)
  final String name;
  final String description;
  final String category;
  final String address;
  final String contactInfo;
  final String? website; // opcional
  final DateTime? createdAt;
  final bool isCancelled;

  /// Banco → objeto.
  factory InstitutionModel.fromMap(Map<String, dynamic> map) {
    return InstitutionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      address: map['address'] as String,
      contactInfo: map['contact_info'] as String,
      website: map['website'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')
          ?.toLocal(),
      isCancelled: map['is_cancelled'] as bool? ?? false,
    );
  }

  /// Objeto → banco (sem id, user_id e created_at, que o banco define).
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'address': address.trim(),
      'contact_info': contactInfo.trim(),
      'website': _nullIfBlank(website),
    };
  }

  /// Texto vazio vira null (campo opcional sem valor).
  static String? _nullIfBlank(String? value) {
    final text = value?.trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
