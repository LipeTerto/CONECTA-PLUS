import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Controllers devem ser liberados quando a tela é destruída.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() roda os validators de todos os campos do Form.
    if (!_formKey.currentState!.validate()) return;

    // TEMPORÁRIO (Etapa 4): só navega. A Etapa 5 troca isto pelo login real.
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
                      subtitle:
                          'Conexão, informação e acolhimento para a comunidade LGBTQIA+',
                    ),
                    const SizedBox(height: 36),
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
                      validator: (value) =>
                          Validators.required(value, 'Informe sua senha'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(label: 'Entrar', onPressed: _submit),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Não tem conta? Cadastre-se'),
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