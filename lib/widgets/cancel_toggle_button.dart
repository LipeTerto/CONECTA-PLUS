import 'package:material_ui/material_ui.dart';

import '../services/service_failure.dart';
import '../utils/app_snackbar.dart';
import 'app_button.dart';
import 'confirm_dialog.dart';

/// Botão do autor para cancelar ou reativar um cadastro.
/// Mostra "Cancelar ..." se estiver ativo e "Reativar ..." se estiver cancelado.
class CancelToggleButton extends StatefulWidget {
  const CancelToggleButton({
    super.key,
    required this.itemName,
    required this.isCancelled,
    required this.onChange,
    required this.onChanged,
  });

  /// Nome do tipo de item, em minúsculas: 'evento', 'instituição'...
  final String itemName;

  /// Estado atual do cadastro.
  final bool isCancelled;

  /// Grava o novo estado (chama o service). Recebe true para cancelar.
  final Future<void> Function(bool cancelled) onChange;

  /// Avisado quando o estado mudou com sucesso (a tela recarrega os dados).
  final VoidCallback onChanged;

  @override
  State<CancelToggleButton> createState() => _CancelToggleButtonState();
}

class _CancelToggleButtonState extends State<CancelToggleButton> {
  bool _isBusy = false;

  Future<void> _toggle() async {
    final cancelling = !widget.isCancelled;

    final confirmed = await showConfirmDialog(
      context,
      title: cancelling
          ? 'Cancelar ${widget.itemName}?'
          : 'Reativar ${widget.itemName}?',
      message: cancelling
          ? 'Este cadastro ficará marcado como CANCELADO e todos os usuários '
                'verão esse aviso. Você poderá reativá-lo depois.'
          : 'O aviso de cancelamento será removido e o cadastro voltará a '
                'aparecer como ativo.',
      confirmLabel: cancelling ? 'Sim, cancelar' : 'Sim, reativar',
      cancelLabel: 'Voltar',
      destructive: cancelling,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await widget.onChange(cancelling);
      if (!mounted) return;
      showAppSnackBar(
        context,
        cancelling ? 'Marcado como cancelado.' : 'Cancelamento removido.',
      );
      widget.onChanged();
    } on ServiceFailure catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: widget.isCancelled
          ? 'Reativar ${widget.itemName}'
          : 'Cancelar ${widget.itemName}',
      icon: widget.isCancelled ? Icons.restore : Icons.event_busy_outlined,
      outlined: true,
      isLoading: _isBusy,
      onPressed: _toggle,
    );
  }
}
