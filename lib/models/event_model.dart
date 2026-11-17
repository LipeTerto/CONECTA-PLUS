import 'package:material_ui/material_ui.dart';

/// Evento (tabela `events`).
class EventModel {
  const EventModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.eventDate,
    required this.eventTime,
    required this.locationName,
    required this.address,
    required this.organizerName,
    this.createdAt,
  });

  final String? id; // null até o evento ser salvo
  final String? userId; // autor (preenchido pelo banco)
  final String title;
  final String description;
  final String category;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String locationName;
  final String address;
  final String organizerName;
  final DateTime? createdAt;

  /// Banco → objeto. O Supabase devolve cada linha como um Map.
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      eventDate: DateTime.parse(map['event_date'] as String), // "2026-12-20"
      eventTime: _parseTime(map['event_time'] as String), // "19:30:00"
      locationName: map['location_name'] as String,
      address: map['address'] as String,
      organizerName: map['organizer_name'] as String,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')
          ?.toLocal(),
    );
  }

  /// Objeto → banco. Só as colunas que o app grava: id, user_id e created_at
  /// ficam de fora porque o próprio banco os define (default auth.uid()).
  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'event_date': _formatDate(eventDate),
      'event_time': '${_two(eventTime.hour)}:${_two(eventTime.minute)}:00',
      'location_name': locationName.trim(),
      'address': address.trim(),
      'organizer_name': organizerName.trim(),
    };
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
}