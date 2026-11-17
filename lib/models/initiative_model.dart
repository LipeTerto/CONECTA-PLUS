/// Iniciativa / projeto social (tabela `initiatives`).
class InitiativeModel {
  const InitiativeModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.organizationName,
    required this.location,
    this.contactInfo,
    this.createdAt,
  });

  final String? id; // null até ser salva
  final String? userId; // autor (preenchido pelo banco)
  final String title;
  final String description;
  final String category;
  final String organizationName;
  final String location;
  final String? contactInfo; // opcional
  final DateTime? createdAt;

  /// Banco → objeto.
  factory InitiativeModel.fromMap(Map<String, dynamic> map) {
    return InitiativeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      organizationName: map['organization_name'] as String,
      location: map['location'] as String,
      contactInfo: map['contact_info'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')
          ?.toLocal(),
    );
  }

  /// Objeto → banco (sem id, user_id e created_at, que o banco define).
  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'organization_name': organizationName.trim(),
      'location': location.trim(),
      'contact_info': _nullIfBlank(contactInfo),
    };
  }

  /// Texto vazio vira null (campo opcional sem valor).
  static String? _nullIfBlank(String? value) {
    final text = value?.trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}