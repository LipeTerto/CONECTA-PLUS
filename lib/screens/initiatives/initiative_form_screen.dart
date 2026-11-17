import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/initiative_model.dart';
import '../../services/initiative_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

/// Cria uma iniciativa (initiativeId == null) ou edita uma existente.
class InitiativeFormScreen extends StatefulWidget {
  const InitiativeFormScreen({super.key, this.initiativeId});

  final String? initiativeId;

  @override
  State<InitiativeFormScreen> createState() => _InitiativeFormScreenState();
}

class _InitiativeFormScreenState extends State<InitiativeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = InitiativeService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  String? _category;

  // Ao editar, começa "carregando" até buscar o registro no banco.
  late bool _isLoading = widget.initiativeId != null;
  bool _isSaving = false;
  String? _loadError;
  bool _canRetry = true;

  bool get _isEditing => widget.initiativeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadInitiative();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizationController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Modo edição: busca a iniciativa e preenche o formulário.
  Future<void> _loadInitiative() async {
    try {
      final initiative = await _service.fetchById(widget.initiativeId!);
      if (!mounted) return;

      // Barreira de interface: só o autor edita. (O RLS também garante.)
      if (initiative.userId != _service.currentUserId) {
        setState(() {
          _loadError = 'Você só pode editar iniciativas cadastradas por você.';
          _canRetry = false;
          _isLoading = false;
        });
        return;
      }

      _titleController.text = initiative.title;
      _descriptionController.text = initiative.description;
      _organizationController.text = initiative.organizationName;
      _locationController.text = initiative.location;
      _contactController.text = initiative.contactInfo ?? '';

      setState(() {
        _category = AppCategories.initiatives.contains(initiative.category)
            ? initiative.category
            : null;
        _isLoading = false;
      });
    } on ServiceFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _canRetry = true;
        _isLoading = false;
      });
    }
  }

  void _retryLoad() {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    _loadInitiative();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final initiative = InitiativeModel(
      id: widget.initiativeId,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category!,
      organizationName: _organizationController.text,
      location: _locationController.text,
      contactInfo: _contactController.text, // vazio vira null no toMap()
    );

    try {
      if (_isEditing) {
        await _service.update(initiative);
      } else {
        await _service.create(initiative);
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        _isEditing ? 'Iniciativa atualizada!' : 'Iniciativa cadastrada!',
      );
      context.pop();
    } on ServiceFailure catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar iniciativa' : 'Nova iniciativa'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando iniciativa...');
    }

    if (_loadError != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Não foi possível abrir o formulário',
        message: _loadError,
        actionLabel: _canRetry ? 'Tentar novamente' : 'Voltar',
        onAction: _canRetry ? _retryLoad : () => context.pop(),
      );
    }

    return ContentWrapper(
      maxWidth: 560,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Título',
                controller: _titleController,
                validator: (v) => Validators.required(v, 'Informe o título'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.title,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                items: AppCategories.initiatives
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                // onChanged nulo = campo desabilitado (durante o salvamento).
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _category = value),
                validator: (v) => v == null ? 'Selecione uma categoria' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Organização responsável',
                controller: _organizationController,
                validator: (v) =>
                    Validators.required(v, 'Informe a organização responsável'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.groups_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Localização',
                controller: _locationController,
                validator: (v) =>
                    Validators.required(v, 'Informe a localização'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.place_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Contato (opcional)',
                hint: 'Telefone, WhatsApp, e-mail ou rede social',
                controller: _contactController,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.call_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descrição',
                controller: _descriptionController,
                validator: (v) =>
                    Validators.required(v, 'Informe uma descrição'),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _isEditing ? 'Salvar alterações' : 'Cadastrar iniciativa',
                onPressed: _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}