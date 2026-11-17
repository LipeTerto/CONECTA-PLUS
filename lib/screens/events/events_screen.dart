import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/event_model.dart';
import '../../routes/app_router.dart';
import '../../services/event_service.dart';
import '../../services/service_failure.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/item_card.dart';
import '../../widgets/loading_widget.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _service = EventService();
  late Future<List<EventModel>> _eventsFuture = _service.fetchAll();

  /// Busca a lista de novo (ex.: ao voltar de outra tela).
  void _reload() {
    setState(() {
      _eventsFuture = _service.fetchAll();
    });
  }

  /// Usado pelo "puxar para atualizar" (RefreshIndicator).
  Future<void> _refresh() async {
    final future = _service.fetchAll();
    setState(() {
      _eventsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // O erro já é exibido pelo FutureBuilder.
    }
  }

  Future<void> _openForm() async {
    await context.push(AppRoutes.create(AppRoutes.events));
    if (!mounted) return;
    _reload(); // pode ter cadastrado algo novo
  }

  Future<void> _openDetails(EventModel event) async {
    await context.push(AppRoutes.details(AppRoutes.events, event.id!));
    if (!mounted) return;
    _reload(); // pode ter sido editado ou excluído
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Novo evento'),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          // Primeira carga (ou nova tentativa após erro): sem dados ainda.
          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget(message: 'Carregando eventos...');
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

          // Durante um refresh, o FutureBuilder mantém a lista antiga aqui.
          final events = snapshot.data ?? const <EventModel>[];

          if (events.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_busy_outlined,
              title: 'Nenhum evento cadastrado',
              message: 'Seja a primeira pessoa a divulgar um evento da comunidade.',
              actionLabel: 'Cadastrar evento',
              onAction: _openForm,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ContentWrapper(
              child: ListView.separated(
                // Espaço no fim para o botão flutuante não cobrir o último card.
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ItemCard(
                    title: event.title,
                    subtitle: '${Formatters.date(event.eventDate)} • '
                        '${Formatters.time(event.eventTime)} • '
                        '${event.locationName}',
                    category: event.category,
                    icon: Icons.event,
                    color: AppTheme.eventsColor,
                    onTap: () => _openDetails(event),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}