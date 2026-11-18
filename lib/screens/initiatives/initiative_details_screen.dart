import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/initiative_model.dart';
import '../../routes/app_router.dart';
import '../../services/initiative_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/info_row.dart';
import '../../widgets/loading_widget.dart';
import '../../models/favorite_model.dart';
import '../../widgets/favorite_button.dart';

class InitiativeDetailsScreen extends StatefulWidget {
  const InitiativeDetailsScreen({super.key, required this.initiativeId});

  final String initiativeId;

  @override
  State<InitiativeDetailsScreen> createState() =>
      _InitiativeDetailsScreenState();
}

class _InitiativeDetailsScreenState extends State<InitiativeDetailsScreen> {
  final _service = InitiativeService();
  late Future<InitiativeModel> _future =
      _service.fetchById(widget.initiativeId);
  bool _isDeleting = false;

  void _reload() {
    setState(() {
      _future = _service.fetchById(widget.initiativeId);
    });
  }

  Future<void> _edit() async {
    await context.push(
      AppRoutes.edit(AppRoutes.initiatives, widget.initiativeId),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _delete(InitiativeModel initiative) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir iniciativa?',
      message: 'A iniciativa "${initiative.title}" será removida '
          'permanentemente. Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _service.delete(widget.initiativeId);
      if (!mounted) return;
      showAppSnackBar(context, 'Iniciativa excluída.');
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
            appBar: AppBar(
        title: const Text('Detalhes da iniciativa'),
        actions: [
          FavoriteButton(
            type: FavoriteType.initiative,
            itemId: widget.initiativeId,
          ),
        ],
      ),
      body: FutureBuilder<InitiativeModel>(
        future: _future,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget();
          }

          if (isDone && snapshot.hasError) {
            final error = snapshot.error;
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Não foi possível abrir a iniciativa',
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

  Widget _buildContent(InitiativeModel initiative) {
    final textTheme = Theme.of(context).textTheme;
    // Só o autor vê os botões. (A segurança real é do RLS no banco.)
    final isOwner = initiative.userId != null &&
        initiative.userId == _service.currentUserId;

    return ContentWrapper(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            initiative.title,
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
                    value: initiative.category,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: 'Organização responsável',
                    value: initiative.organizationName,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Localização',
                    value: initiative.location,
                  ),
                  if (initiative.contactInfo != null) ...[
                    const SizedBox(height: 16),
                    InfoRow(
                      icon: Icons.call_outlined,
                      label: 'Contato',
                      value: initiative.contactInfo!,
                    ),
                  ],
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
                    'Sobre a iniciativa',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(initiative.description, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (initiative.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Cadastrada em ${Formatters.date(initiative.createdAt!)}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Editar iniciativa',
              icon: Icons.edit_outlined,
              onPressed: _edit,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Excluir iniciativa',
              icon: Icons.delete_outline,
              outlined: true,
              isLoading: _isDeleting,
              onPressed: () => _delete(initiative),
            ),
          ],
        ],
      ),
    );
  }
}