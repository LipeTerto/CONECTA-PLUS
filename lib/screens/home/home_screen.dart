import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/content_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conecta+'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: ContentWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Boas-vindas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boas-vindas ao Conecta+',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encontre eventos, redes de apoio e iniciativas da '
                    'comunidade LGBTQIA+, e contribua com novas indicações.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Acesso rápido
            Text(
              'Acesso rápido',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAccessTile(
                    icon: Icons.event,
                    label: 'Eventos',
                    color: AppTheme.eventsColor,
                    onTap: () => context.go(AppRoutes.events),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessTile(
                    icon: Icons.volunteer_activism,
                    label: 'Rede de apoio',
                    color: AppTheme.institutionsColor,
                    onTap: () => context.go(AppRoutes.institutions),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessTile(
                    icon: Icons.lightbulb,
                    label: 'Iniciativas',
                    color: AppTheme.initiativesColor,
                    onTap: () => context.go(AppRoutes.initiatives),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Destaques
            Text(
              'Destaques recentes',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Os cadastros mais recentes aparecerão aqui quando '
                  'conectarmos os dados (Etapa 6).',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atalho quadrado para um módulo. Privado (começa com _): só esta tela usa.
class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}