import 'package:material_ui/material_ui.dart';

const Color _successColor = Color(0xFF2A9D8F);

/// Mostra uma mensagem rápida na parte de baixo da tela.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : _successColor,
      ),
    );
}