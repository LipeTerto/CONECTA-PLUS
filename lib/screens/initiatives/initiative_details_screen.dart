import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../widgets/empty_state_widget.dart';

class InitiativeDetailsScreen extends StatelessWidget {
  const InitiativeDetailsScreen({super.key, required this.initiativeId});

  final String initiativeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da iniciativa')),
      // TEMPORÁRIO (Etapa 4): esqueleto. O conteúdo real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.lightbulb,
        title: 'Detalhes da iniciativa',
        message: 'ID recebido pela rota: $initiativeId',
        actionLabel: 'Testar rota de edição',
        onAction: () => context.push(
          AppRoutes.edit(AppRoutes.initiatives, initiativeId),
        ),
      ),
    );
  }
}