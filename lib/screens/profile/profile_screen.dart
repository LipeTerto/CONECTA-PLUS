import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/user_model.dart';
import '../../routes/app_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/content_wrapper.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late Future<UserModel> _profileFuture = _authService.fetchCurrentProfile();
  bool _isSigningOut = false;

  void _reload() {
    setState(() => _profileFuture = _authService.fetchCurrentProfile());
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, isError: true);
      setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ContentWrapper(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // FutureBuilder: reconstrói a tela conforme o Future carrega.
            FutureBuilder<UserModel>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(height: 180, child: LoadingWidget());
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Não foi possível carregar o perfil',
                    message: error is AuthFailure ? error.message : null,
                    actionLabel: 'Tentar novamente',
                    onAction: _reload,
                  );
                }
                return _ProfileInfo(profile: snapshot.data!);
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Sair da conta',
              icon: Icons.logout,
              outlined: true,
              isLoading: _isSigningOut,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar com a inicial, nome e e-mail.
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.profile});

  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial =
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppTheme.lilacSurface,
          child: Text(
            initial,
            style: textTheme.headlineMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }
}