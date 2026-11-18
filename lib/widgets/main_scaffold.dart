import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/refresh_signal.dart';

/// Moldura das telas principais: guarda a barra de navegação inferior.
/// O [navigationShell] é a aba atual, entregue pelo GoRouter.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelected(int index) {
    // Início (0) e Favoritos (4) recarregam os dados ao serem abertos.
    if (index == 0) RefreshSignal.refreshHome();
    if (index == 4) RefreshSignal.refreshFavorites();

    navigationShell.goBranch(
      index,
      // Tocar na aba já ativa volta para a raiz dela.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Apoio',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Iniciativas',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}