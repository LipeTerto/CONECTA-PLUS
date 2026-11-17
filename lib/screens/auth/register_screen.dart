import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TEMPORÁRIO (Etapa 4): a Etapa 5 troca isto pelo cadastro real.
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandHeader(
                      subtitle: 'Crie sua conta e faça parte da comunidade',
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Nome',
                      controller: _nameController,
                      validator: (value) =>
                          Validators.required(value, 'Informe seu nome'),
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Senha',
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirmar senha',
                      controller: _confirmController,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(label: 'Criar conta', onPressed: _submit),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Já tem conta? Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}