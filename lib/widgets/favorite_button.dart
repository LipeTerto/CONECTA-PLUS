import 'package:material_ui/material_ui.dart';

import '../models/favorite_model.dart';
import '../services/favorite_service.dart';
import '../services/service_failure.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';

/// Coração para favoritar/desfavoritar um item (evento, instituição ou
/// iniciativa). Pensado para ficar nas `actions` da AppBar.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.type, required this.itemId});

  final FavoriteType type;
  final String itemId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _service = FavoriteService();

  bool? _isFavorite; // null = ainda descobrindo
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await _service.isFavorite(widget.type, widget.itemId);
      if (!mounted) return;
      setState(() => _isFavorite = value);
    } on ServiceFailure {
      // Falha silenciosa: mostra o coração vazio. Se o usuário tocar e o
      // item já for favorito, o service trata isso sem erro.
      if (!mounted) return;
      setState(() => _isFavorite = false);
    }
  }

  Future<void> _toggle() async {
    final current = _isFavorite;
    if (current == null || _isBusy) return;

    setState(() => _isBusy = true);
    try {
      if (current) {
        await _service.remove(widget.type, widget.itemId);
      } else {
        await _service.add(widget.type, widget.itemId);
      }
      if (!mounted) return;
      setState(() => _isFavorite = !current);
      showAppSnackBar(
        context,
        current ? 'Removido dos favoritos.' : 'Adicionado aos favoritos!',
      );
    } on ServiceFailure catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = _isFavorite;

    if (isFavorite == null) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      onPressed: _isBusy ? null : _toggle,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppTheme.primary : null,
      ),
    );
  }
}