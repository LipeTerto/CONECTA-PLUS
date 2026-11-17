import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      // TEMPORÁRIO (Etapa 4): a lista real vem na Etapa 6.
      body: const EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'Nenhum favorito ainda',
        message:
            'Toque no coração em eventos, instituições e iniciativas '
            'para salvá-los aqui.',
      ),
    );
  }
}