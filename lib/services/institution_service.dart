import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/institution_model.dart';
import 'service_failure.dart';

class InstitutionService {
  InstitutionService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'institutions';

  /// Id do usuário logado (para saber se ele é o autor de um registro).
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Todas as instituições, em ordem alfabética.
  Future<List<InstitutionModel>> fetchAll() async {
    try {
      final rows =
          await _client.from(_table).select().order('name', ascending: true);
      return rows.map(InstitutionModel.fromMap).toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar as instituições.',
      );
    }
  }

    /// Os cadastros mais recentes (usado nos destaques da Home).
  Future<List<InstitutionModel>> fetchRecent({int limit = 3}) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map(InstitutionModel.fromMap).toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar os destaques.',
      );
    }
  }

  Future<InstitutionModel> fetchById(String id) async {
    try {
      final row =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (row == null) {
        throw const ServiceFailure(
          'Instituição não encontrada. Ela pode ter sido excluída.',
        );
      }
      return InstitutionModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar a instituição.',
      );
    }
  }

  /// Cria a instituição. O banco preenche id, user_id e created_at.
  Future<InstitutionModel> create(InstitutionModel institution) async {
    try {
      final row = await _client
          .from(_table)
          .insert(institution.toMap())
          .select()
          .single();
      return InstitutionModel.fromMap(row);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível cadastrar a instituição.',
      );
    }
  }

  Future<InstitutionModel> update(InstitutionModel institution) async {
    final id = institution.id;
    if (id == null) {
      throw const ServiceFailure('Instituição sem identificador.');
    }

    try {
      final rows = await _client
          .from(_table)
          .update(institution.toMap())
          .eq('id', id)
          .select();

      // Com RLS, editar o registro de outra pessoa não gera erro: apenas
      // nenhuma linha é alterada. Por isso conferimos se algo voltou.
      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível salvar: você só pode editar instituições '
          'cadastradas por você.',
        );
      }
      return InstitutionModel.fromMap(rows.first);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível salvar a instituição.',
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      final rows = await _client.from(_table).delete().eq('id', id).select();

      if (rows.isEmpty) {
        throw const ServiceFailure(
          'Não foi possível excluir: a instituição não existe mais ou não '
          'pertence a você.',
        );
      }
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível excluir a instituição.',
      );
    }
  }
}