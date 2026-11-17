/// Validações reutilizáveis para campos de formulário.
/// Cada função devolve null (válido) ou o texto do erro.
class Validators {
  Validators._();

  static String? required(String? value, [String message = 'Campo obrigatório']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'E-mail inválido';
    return null;
  }

  /// O Supabase exige no mínimo 6 caracteres por padrão.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe uma senha';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirme sua senha';
    if (value != password) return 'As senhas não conferem';
    return null;
  }
}