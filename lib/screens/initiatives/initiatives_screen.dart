import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/item_card.dart';

class InitiativesScreen extends StatelessWidget {
  const InitiativesScreen({super.key});

  // TEMPORÁRIO (Etapa 4): dados de exemplo. Na Etapa 6 vêm do Supabase.
  static const List<Map<String, String>> _samples = [
    {
      'id': 'exemplo-1',
      'title': 'Campanha de empregabilidade trans (exemplo)',
      'subtitle': 'Instituto Exemplo • São Paulo',
      'category': 'Empregabilidade',
    },
    {
      'id': 'exemplo-2',
      'title': 'Cursinho popular comunitário (exemplo)',
      'subtitle': 'Coletivo Exemplo • Osasco',
      'category': 'Educação',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciativas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(AppRoutes.create(AppRoutes.initiatives)),
        icon: const Icon(Icons.add),
        label: const Text('Nova iniciativa'),
      ),
      body: ContentWrapper(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: _samples.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _samples[index];
            return ItemCard(
              title: item['title']!,
              subtitle: item['subtitle']!,
              category: item['category']!,
              icon: Icons.lightbulb,
              color: AppTheme.initiativesColor,
              onTap: () => context.push(
                AppRoutes.details(AppRoutes.initiatives, item['id']!),
              ),
            );
          },
        ),
      ),
    );
  }
}