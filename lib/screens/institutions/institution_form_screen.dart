import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state_widget.dart';

/// Serve para criar (institutionId == null) e para editar.
class InstitutionFormScreen extends StatelessWidget {
  const InstitutionFormScreen({super.key, this.institutionId});

  final String? institutionId;

  bool get isEditing => institutionId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar instituição' : 'Nova instituição'),
      ),
      // TEMPORÁRIO (Etapa 4): o formulário real vem na Etapa 6.
      body: EmptyStateWidget(
        icon: Icons.edit_outlined,
        title: isEditing ? 'Modo edição' : 'Modo cadastro',
        message: isEditing
            ? 'Editando a instituição $institutionId'
            : 'Aqui ficará o formulário de nova instituição.',
      ),
    );
  }
}