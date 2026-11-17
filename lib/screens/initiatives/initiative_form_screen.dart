import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state_widget.dart';

/// Serve para criar (initiativeId == null) e para editar.
class InitiativeFormScreen extends StatelessWidget {
  const InitiativeFormScreen({super.key, this.initiativeId});

  final String? initiativeId;

  bool get isEditing => initiativeId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar iniciativa' : 'Nova iniciativa'),
      ),
      // TEMPORÁRIO (Etapa 4): o formulário real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.edit_outlined,
        title: isEditing ? 'Modo edição' : 'Modo cadastro',
        message: isEditing
            ? 'Editando a iniciativa $initiativeId'
            : 'Aqui ficará o formulário de nova iniciativa.',
      ),
    );
  }
}