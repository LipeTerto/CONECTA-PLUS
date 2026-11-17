import 'package:material_ui/material_ui.dart';

/// Campo de formulário padrão. Se [obscureText] for true, exibe um
/// botão para mostrar/ocultar a senha.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      enabled: widget.enabled,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        alignLabelWithHint: widget.maxLines > 1,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}