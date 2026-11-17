import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/event_model.dart';
import '../../routes/app_router.dart';
import '../../services/event_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/info_row.dart';
import '../../widgets/loading_widget.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _service = EventService();
  late Future<EventModel> _eventFuture = _service.fetchById(widget.eventId);
  bool _isDeleting = false;

  void _reload() {
    setState(() {
      _eventFuture = _service.fetchById(widget.eventId);
    });
  }

  Future<void> _edit() async {
    await context.push(AppRoutes.edit(AppRoutes.events, widget.eventId));
    if (!mounted) return;
    _reload(); // mostra os dados atualizados
  }

  Future<void> _delete(EventModel event) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir evento?',
      message: 'O evento "${event.title}" será removido permanentemente. '
          'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _service.delete(widget.eventId);
      if (!mounted) return;
      showAppSnackBar(context, 'Evento excluído.');
      context.pop();
    } on ServiceFailure catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, isError: true);
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do evento')),
      body: FutureBuilder<EventModel>(
        future: _eventFuture,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget();
          }

          if (isDone && snapshot.hasError) {
            final error = snapshot.error;
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Não foi possível abrir o evento',
              message: error is ServiceFailure ? error.message : null,
              actionLabel: 'Voltar',
              onAction: () => context.pop(),
            );
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(EventModel event) {
    final textTheme = Theme.of(context).textTheme;
    // Só o autor vê os botões. (A segurança real é do RLS no banco.)
    final isOwner =
        event.userId != null && event.userId == _service.currentUserId;

    return ContentWrapper(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            event.title,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.sell_outlined,
                    label: 'Categoria',
                    value: event.category,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Data',
                    value: Formatters.longDate(event.eventDate),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.schedule,
                    label: 'Horário',
                    value: Formatters.time(event.eventTime),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Local',
                    value: event.locationName,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.map_outlined,
                    label: 'Endereço',
                    value: event.address,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: 'Organização',
                    value: event.organizerName,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre o evento',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(event.description, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (event.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Cadastrado em ${Formatters.date(event.createdAt!)}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Editar evento',
              icon: Icons.edit_outlined,
              onPressed: _edit,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Excluir evento',
              icon: Icons.delete_outline,
              outlined: true,
              isLoading: _isDeleting,
              onPressed: () => _delete(event),
            ),
          ],
        ],
      ),
    );
  }
}