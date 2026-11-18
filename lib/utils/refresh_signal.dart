import 'package:flutter/foundation.dart';

/// Sinais para recarregar as abas Início e Favoritos quando o usuário volta
/// a elas (a barra inferior mantém o estado de cada aba, que ficaria velho).
class RefreshSignal {
  RefreshSignal._();

  static final ValueNotifier<int> home = ValueNotifier<int>(0);
  static final ValueNotifier<int> favorites = ValueNotifier<int>(0);

  static void refreshHome() => home.value++;
  static void refreshFavorites() => favorites.value++;
}