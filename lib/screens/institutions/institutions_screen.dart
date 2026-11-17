import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/item_card.dart';

class InstitutionsScreen extends StatelessWidget {
  const InstitutionsScreen({super.key});

  // TEMPORÁRIO (Etapa 4): dados de exemplo. Na Etapa 6 vêm do Supabase.
  static const List<Map<String, String>> _samples = [
    {
      'id': 'exemplo-1',
      'title': 'Casa de Acolhimento Arco-Íris (exemplo)',
      'subtitle': 'Rua das Flores, 100 • Centro',
      'category': 'Moradia e acolhimento',
    },
    {
      'id': 'exemplo-2',
      'title': 'Coletivo de Apoio Psicológico (exemplo)',
      'subtitle': 'Atendimento online e presencial',
      'category': 'Apoio psicológico',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rede de apoio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(AppRoutes.create(AppRoutes.institutions)),
        icon: const Icon(Icons.add),
        label: const Text('Nova instituição'),
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
              icon: Icons.volunteer_activism,
              color: AppTheme.institutionsColor,
              onTap: () => context.push(
                AppRoutes.details(AppRoutes.institutions, item['id']!),
              ),
            );
          },
        ),
      ),
    );
  }
}