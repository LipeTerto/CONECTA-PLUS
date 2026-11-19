import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/initiative_model.dart';
import 'service_failure.dart';

class InitiativeService {
  InitiativeService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'initiatives';

  /// Id do usuário logado (para saber se ele é o autor de um registro).
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Todas as iniciativas, da mais recente para a mais antiga.
  Future<List<InitiativeModel>> fetchAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return rows.map(InitiativeModel.fromMap).toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar as iniciativas.',
      );
    }
  }

  /// Os cadastros mais recentes (usado nos destaques da Home).
  Future<List<InitiativeModel>> fetchRecent({int limit = 3}) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map(InitiativeModel.fromMap).toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar os destaques.',
      );
    }
  }

  Future<InitiativeModel> fetchById(String id) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        throw const ServiceFailure(
          'Iniciativa não encontrada. Ela pode ter sido excluída.',
        );
      }
      return InitiativeModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar a iniciativa.',
      );
    }
  }

  /// Cria a iniciativa. O banco preenche id, user_id e created_at.
  Future<InitiativeModel> create(InitiativeModel initiative) async {
    try {
      final row = await _client
          .from(_table)
          .insert(initiative.toMap())
          .select()
          .single();
      return InitiativeModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível cadastrar a iniciativa.',
      );
    }
  }

  Future<InitiativeModel> update(InitiativeModel initiative) async {
    final id = initiative.id;
    if (id == null) {
      throw const ServiceFailure('Iniciativa sem identificador.');
    }

    try {
      final rows = await _client
          .from(_table)
          .update(initiative.toMap())
          .eq('id', id)
          .select();

      // Com RLS, editar o registro de outra pessoa não gera erro: apenas
      // nenhuma linha é alterada. Por isso conferimos se algo voltou.
      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível salvar: você só pode editar iniciativas '
          'cadastradas por você.',
        );
      }
      return InitiativeModel.fromMap(rows.first);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível salvar a iniciativa.',
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      final rows = await _client.from(_table).delete().eq('id', id).select();

      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível excluir: a iniciativa não existe mais ou não '
          'pertence a você.',
        );
      }
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível excluir a iniciativa.',
      );
    }
  }

  Future<void> setCancelled(String id, bool cancelled) async {
    try {
      final rows = await _client
          .from(_table)
          .update({'is_cancelled': cancelled})
          .eq('id', id)
          .select();

      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível alterar o status: apenas quem cadastrou a '
          'iniciativa pode fazer isso.',
        );
      }
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível alterar o status da iniciativa.',
      );
    }
  }
}
