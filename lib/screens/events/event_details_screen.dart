import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../widgets/empty_state_widget.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do evento')),
      // TEMPORÁRIO (Etapa 4): esqueleto. O conteúdo real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.event,
        title: 'Detalhes do evento',
        message: 'ID recebido pela rota: $eventId',
        actionLabel: 'Testar rota de edição',
        onAction: () =>
            context.push(AppRoutes.edit(AppRoutes.events, eventId)),
      ),
    );
  }
}