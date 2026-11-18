import 'event_model.dart';
import 'initiative_model.dart';
import 'institution_model.dart';

/// Os três tipos de item que podem ser favoritados.
/// [column] é a coluna correspondente na tabela `favorites`.
enum FavoriteType {
  event('event_id'),
  institution('institution_id'),
  initiative('initiative_id');

  const FavoriteType(this.column);

  final String column;
}

/// Favorito (tabela `favorites`), já com o item favoritado embutido.
class FavoriteModel {
  const FavoriteModel({
    required this.id,
    this.createdAt,
    this.event,
    this.institution,
    this.initiative,
  });

  final String id;
  final DateTime? createdAt;

  // Exatamente um destes três é preenchido (o banco garante isso).
  final EventModel? event;
  final InstitutionModel? institution;
  final InitiativeModel? initiative;

  /// Qual dos três tipos este favorito representa.
  FavoriteType? get type {
    if (event != null) return FavoriteType.event;
    if (institution != null) return FavoriteType.institution;
    if (initiative != null) return FavoriteType.initiative;
    return null;
  }

  /// Banco → objeto. As chaves 'events', 'institutions' e 'initiatives'
  /// existem porque a consulta pede os dados embutidos (ver FavoriteService).
  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    final eventMap = map['events'] as Map<String, dynamic>?;
    final institutionMap = map['institutions'] as Map<String, dynamic>?;
    final initiativeMap = map['initiatives'] as Map<String, dynamic>?;

    return FavoriteModel(
      id: map['id'] as String,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')
          ?.toLocal(),
      event: eventMap != null ? EventModel.fromMap(eventMap) : null,
      institution: institutionMap != null
          ? InstitutionModel.fromMap(institutionMap)
          : null,
      initiative: initiativeMap != null
          ? InitiativeModel.fromMap(initiativeMap)
          : null,
    );
  }
}