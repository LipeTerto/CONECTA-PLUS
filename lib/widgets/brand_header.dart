import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Cabeçalho com o logo e o nome do app.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.diversity_3, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'Conecta+',
          style: textTheme.headlineMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }
}