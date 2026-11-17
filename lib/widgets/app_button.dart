import 'package:material_ui/material_ui.dart';

/// Botão padrão do app. Mostra um indicador de carregamento e fica
/// desabilitado enquanto [isLoading] for verdadeiro.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Widget content = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final VoidCallback? action = isLoading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: action, child: content)
          : FilledButton(onPressed: action, child: content),
    );
  }
}