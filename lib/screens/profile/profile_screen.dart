import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/content_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ContentWrapper(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppTheme.lilacSurface,
                child: Icon(Icons.person, size: 48, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            // TEMPORÁRIO (Etapa 4): dados reais vêm do usuário na Etapa 5.
            Center(
              child: Text(
                'Nome do usuário',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'email@exemplo.com',
                style: textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Sair da conta',
              icon: Icons.logout,
              outlined: true,
              // TEMPORÁRIO: a Etapa 5 troca por logout de verdade.
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}