import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/item_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  // TEMPORÁRIO (Etapa 4): dados de exemplo. Na Etapa 6 vêm do Supabase.
  static const List<Map<String, String>> _samples = [
    {
      'id': 'exemplo-1',
      'title': 'Sarau de poesia e música (exemplo)',
      'subtitle': '20/12 • 19h • Centro Cultural',
      'category': 'Cultura e arte',
    },
    {
      'id': 'exemplo-2',
      'title': 'Roda de conversa sobre acolhimento (exemplo)',
      'subtitle': '05/01 • 15h • Espaço Comunitário',
      'category': 'Palestra e debate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.create(AppRoutes.events)),
        icon: const Icon(Icons.add),
        label: const Text('Novo evento'),
      ),
      body: ContentWrapper(
        child: ListView.separated(
          // Espaço no fim para o botão flutuante não cobrir o último card.
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: _samples.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _samples[index];
            return ItemCard(
              title: item['title']!,
              subtitle: item['subtitle']!,
              category: item['category']!,
              icon: Icons.event,
              color: AppTheme.eventsColor,
              onTap: () => context.push(
                AppRoutes.details(AppRoutes.events, item['id']!),
              ),
            );
          },
        ),
      ),
    );
  }
}