import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/service_failure.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

/// Cria um evento (eventId == null) ou edita um existente (eventId preenchido).
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  final String? eventId;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EventService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _organizerController = TextEditingController();
  final _dateController = TextEditingController(); // texto exibido
  final _timeController = TextEditingController(); // texto exibido

  String? _category;
  DateTime? _date; // valor real escolhido no calendário
  TimeOfDay? _time; // valor real escolhido no relógio

  // Ao editar, começa "carregando" até buscar o evento no banco.
  late bool _isLoading = widget.eventId != null;
  bool _isSaving = false;
  String? _loadError;
  bool _canRetry = true;

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadEvent();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _organizerController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Modo edição: busca o evento e preenche o formulário.
  Future<void> _loadEvent() async {
    try {
      final event = await _service.fetchById(widget.eventId!);
      if (!mounted) return;

      // Barreira de interface: só o autor edita. (O RLS também garante.)
      if (event.userId != _service.currentUserId) {
        setState(() {
          _loadError = 'Você só pode editar eventos cadastrados por você.';
          _canRetry = false;
          _isLoading = false;
        });
        return;
      }

      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.locationName;
      _addressController.text = event.address;
      _organizerController.text = event.organizerName;
      _dateController.text = Formatters.date(event.eventDate);
      _timeController.text = Formatters.time(event.eventTime);

      setState(() {
        _category =
            AppCategories.events.contains(event.category) ? event.category : null;
        _date = event.eventDate;
        _time = event.eventTime;
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
    _loadEvent();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data do evento',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateController.text = Formatters.date(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: 'Selecione o horário',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeController.text = Formatters.time(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final event = EventModel(
      id: widget.eventId,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category!,
      eventDate: _date!,
      eventTime: _time!,
      locationName: _locationController.text,
      address: _addressController.text,
      organizerName: _organizerController.text,
    );

    try {
      if (_isEditing) {
        await _service.update(event);
      } else {
        await _service.create(event);
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        _isEditing ? 'Evento atualizado!' : 'Evento cadastrado!',
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar evento' : 'Novo evento')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando evento...');
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
                items: AppCategories.events
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Data',
                      controller: _dateController,
                      validator: (v) =>
                          Validators.required(v, 'Selecione a data'),
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: Icons.calendar_today_outlined,
                      enabled: !_isSaving,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Horário',
                      controller: _timeController,
                      validator: (v) =>
                          Validators.required(v, 'Selecione o horário'),
                      readOnly: true,
                      onTap: _pickTime,
                      prefixIcon: Icons.schedule,
                      enabled: !_isSaving,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nome do local',
                controller: _locationController,
                validator: (v) => Validators.required(v, 'Informe o local'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.place_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Endereço',
                controller: _addressController,
                validator: (v) => Validators.required(v, 'Informe o endereço'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.map_outlined,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Organização / responsável',
                controller: _organizerController,
                validator: (v) =>
                    Validators.required(v, 'Informe quem organiza o evento'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.groups_outlined,
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
                label: _isEditing ? 'Salvar alterações' : 'Cadastrar evento',
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