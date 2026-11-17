import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../widgets/empty_state_widget.dart';

class InstitutionDetailsScreen extends StatelessWidget {
  const InstitutionDetailsScreen({super.key, required this.institutionId});

  final String institutionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da instituição')),
      // TEMPORÁRIO (Etapa 4): esqueleto. O conteúdo real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.volunteer_activism,
        title: 'Detalhes da instituição',
        message: 'ID recebido pela rota: $institutionId',
        actionLabel: 'Testar rota de edição',
        onAction: () => context.push(
          AppRoutes.edit(AppRoutes.institutions, institutionId),
        ),
      ),
    );
  }
}