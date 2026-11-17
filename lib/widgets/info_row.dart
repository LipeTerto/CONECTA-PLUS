import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 2),
              // Selecionável: permite copiar telefone, endereço, site etc.
              SelectableText(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}