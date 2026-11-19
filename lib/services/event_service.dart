import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event_model.dart';
import 'service_failure.dart';

class EventService {
  EventService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'events';

  /// Id do usuário logado (usado para saber se ele é o autor de um evento).
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Todos os eventos: primeiro os próximos (do mais perto ao mais longe),
  /// depois os já realizados (do mais recente ao mais antigo).
  Future<List<EventModel>> fetchAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('event_date', ascending: true)
          .order('event_time', ascending: true);

      final events = rows.map(EventModel.fromMap).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcoming = events
          .where((e) => !e.eventDate.isBefore(today))
          .toList();
      final past = events.where((e) => e.eventDate.isBefore(today)).toList();

      return [...upcoming, ...past.reversed];
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar os eventos.',
      );
    }
  }

  /// Os cadastros mais recentes (usado nos destaques da Home).
  Future<List<EventModel>> fetchRecent({int limit = 3}) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map(EventModel.fromMap).toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar os destaques.',
      );
    }
  }

  Future<EventModel> fetchById(String id) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        throw const ServiceFailure(
          'Evento não encontrado. Ele pode ter sido excluído.',
        );
      }
      return EventModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar o evento.',
      );
    }
  }

  /// Cria o evento. O banco preenche id, user_id (= usuário logado) e created_at.
  Future<EventModel> create(EventModel event) async {
    try {
      final row = await _client
          .from(_table)
          .insert(event.toMap())
          .select()
          .single();
      return EventModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível cadastrar o evento.',
      );
    }
  }

  Future<EventModel> update(EventModel event) async {
    final id = event.id;
    if (id == null) throw const ServiceFailure('Evento sem identificador.');

    try {
      // .select() no final faz o banco devolver as linhas alteradas.
      final rows = await _client
          .from(_table)
          .update(event.toMap())
          .eq('id', id)
          .select();

      // Com RLS, editar um registro de outra pessoa NÃO gera erro: o banco
      // apenas não encontra nenhuma linha "visível para edição". Por isso
      // conferimos se alguma linha foi realmente alterada.
      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível salvar: você só pode editar eventos cadastrados por você.',
        );
      }
      return EventModel.fromMap(rows.first);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível salvar o evento.',
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      final rows = await _client.from(_table).delete().eq('id', id).select();

      // Mesma lógica do update: zero linhas = nada foi excluído.
      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível excluir: o evento não existe mais ou não pertence a você.',
        );
      }
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível excluir o evento.',
      );
    }
  }

  /// Marca (ou desmarca) o evento como cancelado.
  Future<void> setCancelled(String id, bool cancelled) async {
    try {
      final rows = await _client
          .from(_table)
          .update({'is_cancelled': cancelled})
          .eq('id', id)
          .select();

      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível alterar o status: apenas quem cadastrou o '
          'evento pode fazer isso.',
        );
      }
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível alterar o status do evento.',
      );
    }
  }
}
