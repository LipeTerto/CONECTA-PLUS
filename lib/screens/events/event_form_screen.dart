import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state_widget.dart';

/// Serve para criar (eventId == null) e para editar (eventId preenchido).
class EventFormScreen extends StatelessWidget {
  const EventFormScreen({super.key, this.eventId});

  final String? eventId;

  bool get isEditing => eventId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar evento' : 'Novo evento')),
      // TEMPORÁRIO (Etapa 4): o formulário real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.edit_outlined,
        title: isEditing ? 'Modo edição' : 'Modo cadastro',
        message: isEditing
            ? 'Editando o evento $eventId'
            : 'Aqui ficará o formulário de novo evento.',
      ),
    );
  }
}