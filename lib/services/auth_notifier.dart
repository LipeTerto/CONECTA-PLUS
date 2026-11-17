import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Observa o estado de login do Supabase e avisa o roteador quando muda.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  /// Há uma sessão ativa (usuário logado)?
  bool get isLoggedIn =>
      Supabase.instance.client.auth.currentSession != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}