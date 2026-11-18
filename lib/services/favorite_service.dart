import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_model.dart';
import 'service_failure.dart';

class FavoriteService {
  FavoriteService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'favorites';

  /// Favoritos do usuário logado, do mais recente para o mais antigo.
  /// O RLS já garante que só as linhas dele voltam.
  Future<List<FavoriteModel>> fetchAll() async {
    try {
      // 'events(*)' etc. pedem os dados do item junto com cada favorito.
      final rows = await _client
          .from(_table)
          .select('*, events(*), institutions(*), initiatives(*)')
          .order('created_at', ascending: false);

      return rows
          .map(FavoriteModel.fromMap)
          .where((favorite) => favorite.type != null)
          .toList();
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível carregar seus favoritos.',
      );
    }
  }

  /// Este item já está nos favoritos do usuário?
  Future<bool> isFavorite(FavoriteType type, String itemId) async {
    try {
      // Não filtramos por user_id: o RLS só deixa enxergar as linhas dele.
      final row = await _client
          .from(_table)
          .select('id')
          .eq(type.column, itemId)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível verificar os favoritos.',
      );
    }
  }

  /// Adiciona aos favoritos. O banco preenche user_id (= usuário logado).
  Future<void> add(FavoriteType type, String itemId) async {
    try {
      await _client.from(_table).insert({type.column: itemId});
    } on PostgrestException catch (e) {
      // 23505 = violação de UNIQUE: já era favorito. Para o usuário, o
      // resultado é o mesmo que ele queria, então tratamos como sucesso.
      if (e.code == '23505') return;
      // 23503 = violação de chave estrangeira: o item foi excluído.
      if (e.code == '23503') {
        throw const ServiceFailure('Este item não existe mais.');
      }
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível adicionar aos favoritos.',
      );
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível adicionar aos favoritos.',
      );
    }
  }

  Future<void> remove(FavoriteType type, String itemId) async {
    try {
      await _client.from(_table).delete().eq(type.column, itemId);
    } catch (e) {
      throw ServiceFailure.from(
        e,
        fallback: 'Não foi possível remover dos favoritos.',
      );
    }
  }
}