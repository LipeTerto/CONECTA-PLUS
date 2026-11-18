import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/initiative_model.dart';
import '../../routes/app_router.dart';
import '../../services/initiative_service.dart';
import '../../services/service_failure.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/item_cards.dart';
import '../../widgets/loading_widget.dart';

class InitiativesScreen extends StatefulWidget {
  const InitiativesScreen({super.key});

  @override
  State<InitiativesScreen> createState() => _InitiativesScreenState();
}

class _InitiativesScreenState extends State<InitiativesScreen> {
  final _service = InitiativeService();
  late Future<List<InitiativeModel>> _future = _service.fetchAll();

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
    await context.push(AppRoutes.create(AppRoutes.initiatives));
    if (!mounted) return;
    _reload();
  }

  Future<void> _openDetails(InitiativeModel initiative) async {
    await context.push(AppRoutes.details(AppRoutes.initiatives, initiative.id!));
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciativas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nova iniciativa'),
      ),
      body: FutureBuilder<List<InitiativeModel>>(
        future: _future,
        builder: (context, snapshot) {
          final isDone = snapshot.connectionState == ConnectionState.done;

          if (!isDone && !snapshot.hasData) {
            return const LoadingWidget(message: 'Carregando iniciativas...');
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

          final items = snapshot.data ?? const <InitiativeModel>[];

          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.lightbulb_outline,
              title: 'Nenhuma iniciativa cadastrada',
              message:
                  'Divulgue um projeto, campanha ou ação comunitária.',
              actionLabel: 'Cadastrar iniciativa',
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
                                    return InitiativeCard(
                    initiative: item,
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