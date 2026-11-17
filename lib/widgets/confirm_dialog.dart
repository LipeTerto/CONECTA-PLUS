import 'package:material_ui/material_ui.dart';

/// Mostra uma caixa "Cancelar / Confirmar". Devolve true se confirmou.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  final errorColor = Theme.of(context).colorScheme.error;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: errorColor)
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  // Se o usuário tocar fora da caixa, o resultado é null: tratamos como "não".
  return result ?? false;
}