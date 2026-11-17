import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de acesso a dados, com mensagem já pronta para o usuário.
class ServiceFailure implements Exception {
  const ServiceFailure(this.message);

  final String message;

  /// Converte qualquer erro técnico em um ServiceFailure amigável.
  factory ServiceFailure.from(
    Object error, {
    String fallback = 'Não foi possível concluir a operação. Tente novamente.',
  }) {
    debugPrint('ServiceFailure: $error'); // detalhe técnico, só no console

    if (error is ServiceFailure) return error;

    if (error is PostgrestException && error.code == '42501') {
      return const ServiceFailure(
        'Você não tem permissão para realizar esta ação.',
      );
    }

    final text = error.toString().toLowerCase();
    if (text.contains('failed to fetch') ||
        text.contains('socketexception') ||
        text.contains('clientexception')) {
      return const ServiceFailure(
        'Falha de conexão. Verifique sua internet e tente novamente.',
      );
    }

    return ServiceFailure(fallback);
  }

  @override
  String toString() => message;
}