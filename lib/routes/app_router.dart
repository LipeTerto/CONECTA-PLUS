import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/events/event_details_screen.dart';
import '../screens/events/event_form_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/initiatives/initiative_details_screen.dart';
import '../screens/initiatives/initiative_form_screen.dart';
import '../screens/initiatives/initiatives_screen.dart';
import '../screens/institutions/institution_details_screen.dart';
import '../screens/institutions/institution_form_screen.dart';
import '../screens/institutions/institutions_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../services/auth_notifier.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_scaffold.dart';

/// TEMPORÁRIO (Etapa 4): com true, a proteção de rotas fica desligada
/// para você navegar pelas telas sem login. Será removido na Etapa 5.
const bool kDevBypassAuth = true;

/// Caminhos de todas as telas, num só lugar (evita erros de digitação).
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const events = '/events';
  static const institutions = '/institutions';
  static const initiatives = '/initiatives';
  static const favorites = '/favorites';
  static const profile = '/profile';

  // Montam os caminhos de cada módulo: AppRoutes.details(AppRoutes.events, id)
  static String create(String section) => '$section/new';
  static String details(String section, String id) => '$section/$id';
  static String edit(String section, String id) => '$section/$id/edit';
}

class AppRouter {
  AppRouter._();

  static final AuthNotifier authNotifier = AuthNotifier();
  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: _redirect,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Conecta+')),
      body: const EmptyStateWidget(
        icon: Icons.search_off,
        title: 'Página não encontrada',
        message: 'O endereço que você tentou abrir não existe.',
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Telas com barra inferior: cada aba é um "branch" com estado próprio.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            _crudRoute(
              path: AppRoutes.events,
              list: const EventsScreen(),
              details: (id) => EventDetailsScreen(eventId: id),
              form: (id) => EventFormScreen(eventId: id),
            ),
          ]),
          StatefulShellBranch(routes: [
            _crudRoute(
              path: AppRoutes.institutions,
              list: const InstitutionsScreen(),
              details: (id) => InstitutionDetailsScreen(institutionId: id),
              form: (id) => InstitutionFormScreen(institutionId: id),
            ),
          ]),
          StatefulShellBranch(routes: [
            _crudRoute(
              path: AppRoutes.initiatives,
              list: const InitiativesScreen(),
              details: (id) => InitiativeDetailsScreen(initiativeId: id),
              form: (id) => InitiativeFormScreen(initiativeId: id),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => const FavoritesScreen(),
            ),
          ]),
        ],
      ),
    ],
  );

  /// Monta as 4 rotas de um módulo: lista, novo, detalhes e editar.
  /// Detalhes e formulários abrem POR CIMA da barra inferior
  /// (parentNavigatorKey: _rootKey) e ficam em tela cheia.
  static GoRoute _crudRoute({
    required String path,
    required Widget list,
    required Widget Function(String id) details,
    required Widget Function(String? id) form,
  }) {
    return GoRoute(
      path: path,
      builder: (context, state) => list,
      routes: [
        // 'new' vem ANTES de ':id', senão "new" seria lido como um id.
        GoRoute(
          path: 'new',
          parentNavigatorKey: _rootKey,
          builder: (context, state) => form(null),
        ),
        GoRoute(
          path: ':id',
          parentNavigatorKey: _rootKey,
          builder: (context, state) => details(state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              parentNavigatorKey: _rootKey,
              builder: (context, state) =>
                  form(state.pathParameters['id']),
            ),
          ],
        ),
      ],
    );
  }

  /// Roda a cada navegação e decide se é preciso redirecionar.
  static String? _redirect(BuildContext context, GoRouterState state) {
    if (kDevBypassAuth) return null;

    final loggedIn = authNotifier.isLoggedIn;
    final location = state.matchedLocation;
    final onAuthScreen =
        location == AppRoutes.login || location == AppRoutes.register;

    if (!loggedIn && !onAuthScreen) return AppRoutes.login;
    if (loggedIn && onAuthScreen) return AppRoutes.home;
    return null; // null = pode seguir para onde queria ir
  }
}