import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/institution_model.dart';
import '../../services/institution_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

/// Cria uma instituição (institutionId == null) ou edita uma existente.
class InstitutionFormScreen extends StatefulWidget {
  const InstitutionFormScreen({super.key, this.institutionId});

  final String? institutionId;

  @override
  State<InstitutionFormScreen> createState() => _InstitutionFormScreenState();
}

class _InstitutionFormScreenState extends State<InstitutionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = InstitutionService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _category;

  // Ao editar, começa "carregando" até buscar o registro no banco.
  late bool _isLoading = widget.institutionId != null;
  bool _isSaving = false;
  String? _loadError;
  bool _canRetry = true;

  bool get _isEditing => widget.institutionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadInstitution();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  /// Modo edição: busca a instituição e preenche o formulário.
  Future<void> _loadInstitution() async {
    try {
      final institution = await _service.fetchById(widget.institutionId!);
      if (!mounted) return;

      // Barreira de interface: só o autor edita. (O RLS também garante.)
      if (institution.userId != _service.currentUserId) {
        setState(() {
          _loadError =
              'Você só pode editar instituições cadastradas por você.';
          _canRetry = false;
          _isLoading = false;
        });
        return;
      }

      _nameController.text = institution.name;
      _descriptionController.text = institution.description;
      _addressController.text = institution.address;
      _contactController.text = institution.contactInfo;
      _websiteController.text = institution.website ?? '';

      setState(() {
        _category = AppCategories.institutions.contains(institution.category)
            ? institution.category
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
    _loadInstitution();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final institution = InstitutionModel(
      id: widget.institutionId,
      name: _nameController.text,
      description: _descriptionController.text,
      category: _category!,
      address: _addressController.text,
      contactInfo: _contactController.text,
      website: _websiteController.text, // vazio vira null no toMap()
    );

    try {
      if (_isEditing) {
        await _service.update(institution);
      } else {
        await _service.create(institution);
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        _isEditing ? 'Instituição atualizada!' : 'Instituição cadastrada!',
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
        title: Text(_isEditing ? 'Editar instituição' : 'Nova instituição'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando instituição...');
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
                label: 'Nome da instituição',
                controller: _nameController,
                validator: (v) => Validators.required(v, 'Informe o nome'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.business_outlined,
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
                items: AppCategories.institutions
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
                label: 'Endereço ou localização',
                controller: _addressController,
                validator: (v) =>
                    Validators.required(v, 'Informe o endereço ou a localização'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.map_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Contato',
                hint: 'Telefone, WhatsApp ou e-mail',
                controller: _contactController,
                validator: (v) =>
                    Validators.required(v, 'Informe uma forma de contato'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.call_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Site ou rede social (opcional)',
                hint: 'www.exemplo.com ou @perfil',
                controller: _websiteController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.language,
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
                label:
                    _isEditing ? 'Salvar alterações' : 'Cadastrar instituição',
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