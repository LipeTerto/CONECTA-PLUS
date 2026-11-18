import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/favorite_model.dart';
import '../../routes/app_router.dart';
import '../../services/favorite_service.dart';
import '../../services/service_failure.dart';
import '../../utils/refresh_signal.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/item_cards.dart';
import '../../widgets/loading_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = FavoriteService();
  late Future<List<FavoriteModel>> _future = _service.fetchAll();

  @override
  void initState() {
    super.initState();
    // Recarrega quando o usuário volta para esta aba.
    RefreshSignal.favorites.addListener(_reload);
  }

  @override
  void dispose() {
    RefreshSignal.favorites.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchAll();
    });
  }

  Future<void> _refresh() async {
    final future = _service.fetchAll();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // O erro já é exibido pelo FutureBuilder.
    }
  }

  Future<void> _open(String section, String id) async {
    await context.push(AppRoutes.details(section, id));
    if (!mounted) return;
    _reload(); // o usuário pode ter removido o favorito
  }

  Widget _buildCard(FavoriteModel favorite) {
    final event = favorite.event;
    final institution = favorite.institution;
    final initiative = favorite.initiative;

    if (event != null) {
      return EventCard(
        event: event,
        onTap: () => _open(AppRoutes.events, event.id!),
      );
    }
    if (institution != null) {
      return InstitutionCard(
        institution: institution,
        onTap: () => _open(AppRoutes.institutions, institution.id!),
      );
    }
    if (initiative != null) {
      return InitiativeCard(
        initiative: initiative,
        onTap: () => _open(AppRoutes.initiatives, initiative.id!),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<List<FavoriteModel>>(
        future: _future,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget(message: 'Carregando favoritos...');
          }

          if (isDone && snapshot.hasError) {
            final error = snapshot.error;
            return EmptyStateWidget(
              icon: Icons.cloud_off_outlined,
              title: 'Não foi possível carregar',
              message: error is ServiceFailure ? error.message : null,
              actionLabel: 'Tentar novamente',
              onAction: _reload,
            );
          }

          final favorites = snapshot.data ?? const <FavoriteModel>[];

          if (favorites.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Nenhum favorito ainda',
              message: 'Toque no coração nos detalhes de eventos, '
                  'instituições e iniciativas para salvá-los aqui.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ContentWrapper(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildCard(favorites[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}