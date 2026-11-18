import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/event_model.dart';
import '../../models/initiative_model.dart';
import '../../models/institution_model.dart';
import '../../routes/app_router.dart';
import '../../services/event_service.dart';
import '../../services/initiative_service.dart';
import '../../services/institution_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/refresh_signal.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/item_cards.dart';
import '../../widgets/loading_widget.dart';

/// Um cadastro recente (de qualquer módulo) com sua data, para ordenar.
class _Highlight {
  const _Highlight(this.createdAt, this.item);

  final DateTime createdAt;
  final Object item; // EventModel, InstitutionModel ou InitiativeModel
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _eventService = EventService();
  final _institutionService = InstitutionService();
  final _initiativeService = InitiativeService();

  late Future<List<_Highlight>> _highlightsFuture = _loadHighlights();

  @override
  void initState() {
    super.initState();
    // Recarrega os destaques quando o usuário volta para esta aba.
    RefreshSignal.home.addListener(_reload);
  }

  @override
  void dispose() {
    RefreshSignal.home.removeListener(_reload);
    super.dispose();
  }

  /// Busca os 3 mais recentes de cada módulo (em paralelo), mistura, ordena
  /// por data de cadastro e fica com os 5 mais novos.
  Future<List<_Highlight>> _loadHighlights() async {
    final (events, institutions, initiatives) = await (
      _eventService.fetchRecent(),
      _institutionService.fetchRecent(),
      _initiativeService.fetchRecent(),
    ).wait;

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final items = <_Highlight>[
      for (final e in events) _Highlight(e.createdAt ?? epoch, e),
      for (final i in institutions) _Highlight(i.createdAt ?? epoch, i),
      for (final n in initiatives) _Highlight(n.createdAt ?? epoch, n),
    ];

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(5).toList();
  }

  void _reload() {
    setState(() {
      _highlightsFuture = _loadHighlights();
    });
  }

  Future<void> _refresh() async {
    final future = _loadHighlights();
    setState(() {
      _highlightsFuture = future;
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
    _reload();
  }

  Widget _buildCard(Object item) {
    // switch com padrão de tipo (Dart 3): escolhe o card conforme o item.
    return switch (item) {
      EventModel e => EventCard(
          event: e,
          onTap: () => _open(AppRoutes.events, e.id!),
        ),
      InstitutionModel i => InstitutionCard(
          institution: i,
          onTap: () => _open(AppRoutes.institutions, i.id!),
        ),
      InitiativeModel n => InitiativeCard(
          initiative: n,
          onTap: () => _open(AppRoutes.initiatives, n.id!),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildHighlights() {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<_Highlight>>(
      future: _highlightsFuture,
      builder: (context, snapshot) {
        final isDone = snapshot.connectionState == ConnectionState.done;

        if (!isDone && !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: LoadingWidget(),
          );
        }

        if (isDone && snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Não foi possível carregar os destaques.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = snapshot.data ?? const <_Highlight>[];

        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Ainda não há cadastros. Que tal ser a primeira pessoa a '
                'contribuir com um evento, instituição ou iniciativa?',
                style:
                    textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final highlight in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(highlight.item),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conecta+'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ContentWrapper(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Boas-vindas
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boas-vindas ao Conecta+',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Encontre eventos, redes de apoio e iniciativas da '
                      'comunidade LGBTQIA+, e contribua com novas indicações.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Acesso rápido
              Text(
                'Acesso rápido',
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAccessTile(
                      icon: Icons.event,
                      label: 'Eventos',
                      color: AppTheme.eventsColor,
                      onTap: () => context.go(AppRoutes.events),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAccessTile(
                      icon: Icons.volunteer_activism,
                      label: 'Rede de apoio',
                      color: AppTheme.institutionsColor,
                      onTap: () => context.go(AppRoutes.institutions),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAccessTile(
                      icon: Icons.lightbulb,
                      label: 'Iniciativas',
                      color: AppTheme.initiativesColor,
                      onTap: () => context.go(AppRoutes.initiatives),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Destaques
              Text(
                'Destaques recentes',
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildHighlights(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Atalho quadrado para um módulo. Privado (começa com _): só esta tela usa.
class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}