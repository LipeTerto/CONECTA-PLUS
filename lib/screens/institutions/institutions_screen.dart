import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/institution_model.dart';
import '../../routes/app_router.dart';
import '../../services/institution_service.dart';
import '../../services/service_failure.dart';
import '../../theme/app_theme.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/item_card.dart';
import '../../widgets/loading_widget.dart';

class InstitutionsScreen extends StatefulWidget {
  const InstitutionsScreen({super.key});

  @override
  State<InstitutionsScreen> createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends State<InstitutionsScreen> {
  final _service = InstitutionService();
  late Future<List<InstitutionModel>> _future = _service.fetchAll();

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

  Future<void> _openForm() async {
    await context.push(AppRoutes.create(AppRoutes.institutions));
    if (!mounted) return;
    _reload();
  }

  Future<void> _openDetails(InstitutionModel institution) async {
    await context.push(AppRoutes.details(AppRoutes.institutions, institution.id!));
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rede de apoio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nova instituição'),
      ),
      body: FutureBuilder<List<InstitutionModel>>(
        future: _future,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget(message: 'Carregando instituições...');
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

          final items = snapshot.data ?? const <InstitutionModel>[];

          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.volunteer_activism_outlined,
              title: 'Nenhuma instituição cadastrada',
              message:
                  'Indique uma ONG, coletivo ou espaço de acolhimento para a comunidade.',
              actionLabel: 'Cadastrar instituição',
              onAction: _openForm,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ContentWrapper(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ItemCard(
                    title: item.name,
                    subtitle: item.address,
                    category: item.category,
                    icon: Icons.volunteer_activism,
                    color: AppTheme.institutionsColor,
                    onTap: () => _openDetails(item),
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