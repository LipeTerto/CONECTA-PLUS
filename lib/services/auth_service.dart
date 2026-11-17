import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

/// Erro de autenticação com mensagem já pronta para mostrar ao usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _connectionMessage =
      'Falha de conexão. Verifique sua internet e tente novamente.';

  /// Usuário logado no momento (null se ninguém estiver logado).
  User? get currentUser => _client.auth.currentUser;

  /// Cria a conta. Devolve true se o usuário já ficou logado, ou false se o
  /// projeto exige confirmação por e-mail antes do primeiro login.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()}, // o trigger copia para profiles.name
      );
      return response.session != null;
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (e) {
      debugPrint('signUp error: $e');
      throw const AuthFailure(_connectionMessage);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (e) {
      debugPrint('signIn error: $e');
      throw const AuthFailure(_connectionMessage);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (e) {
      debugPrint('signOut error: $e');
      throw const AuthFailure(_connectionMessage);
    }
  }

  /// Busca o perfil do usuário logado na tabela `profiles`.
  Future<UserModel> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Sessão expirada. Entre novamente.');
    }

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) return UserModel.fromMap(data);

      // Plano B: se a linha de perfil não existir, usa os dados do login.
      return UserModel(
        id: user.id,
        name: (user.userMetadata?['name'] as String?) ?? 'Usuário',
        email: user.email ?? '',
      );
    } catch (e) {
      debugPrint('fetchCurrentProfile error: $e');
      throw const AuthFailure('Não foi possível carregar o perfil.');
    }
  }

  /// Traduz as mensagens (em inglês) do Supabase para português.
  String _translate(AuthException e) {
    debugPrint('AuthException: ${e.message}'); // útil para depurar no console
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return 'Senha muito fraca. Use pelo menos 6 caracteres.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
    }
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid format')) {
      return 'E-mail inválido.';
    }
    if (msg.contains('failed to fetch') ||
        msg.contains('socketexception') ||
        msg.contains('clientexception')) {
      return _connectionMessage;
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}