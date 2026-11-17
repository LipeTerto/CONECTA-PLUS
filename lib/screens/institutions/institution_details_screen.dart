import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/institution_model.dart';
import '../../routes/app_router.dart';
import '../../services/institution_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/info_row.dart';
import '../../widgets/loading_widget.dart';

class InstitutionDetailsScreen extends StatefulWidget {
  const InstitutionDetailsScreen({super.key, required this.institutionId});

  final String institutionId;

  @override
  State<InstitutionDetailsScreen> createState() =>
      _InstitutionDetailsScreenState();
}

class _InstitutionDetailsScreenState extends State<InstitutionDetailsScreen> {
  final _service = InstitutionService();
  late Future<InstitutionModel> _future =
      _service.fetchById(widget.institutionId);
  bool _isDeleting = false;

  void _reload() {
    setState(() {
      _future = _service.fetchById(widget.institutionId);
    });
  }

  Future<void> _edit() async {
    await context.push(
      AppRoutes.edit(AppRoutes.institutions, widget.institutionId),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _delete(InstitutionModel institution) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir instituição?',
      message: 'A instituição "${institution.name}" será removida '
          'permanentemente. Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _service.delete(widget.institutionId);
      if (!mounted) return;
      showAppSnackBar(context, 'Instituição excluída.');
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
      appBar: AppBar(title: const Text('Detalhes da instituição')),
      body: FutureBuilder<InstitutionModel>(
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
              title: 'Não foi possível abrir a instituição',
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

  Widget _buildContent(InstitutionModel institution) {
    final textTheme = Theme.of(context).textTheme;
    // Só o autor vê os botões. (A segurança real é do RLS no banco.)
    final isOwner = institution.userId != null &&
        institution.userId == _service.currentUserId;

    return ContentWrapper(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            institution.name,
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
                    value: institution.category,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.map_outlined,
                    label: 'Endereço / localização',
                    value: institution.address,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.call_outlined,
                    label: 'Contato',
                    value: institution.contactInfo,
                  ),
                  if (institution.website != null) ...[
                    const SizedBox(height: 16),
                    InfoRow(
                      icon: Icons.language,
                      label: 'Site ou rede social',
                      value: institution.website!,
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
                    'Sobre a instituição',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(institution.description, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (institution.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Cadastrada em ${Formatters.date(institution.createdAt!)}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Editar instituição',
              icon: Icons.edit_outlined,
              onPressed: _edit,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Excluir instituição',
              icon: Icons.delete_outline,
              outlined: true,
              isLoading: _isDeleting,
              onPressed: () => _delete(institution),
            ),
          ],
        ],
      ),
    );
  }
}