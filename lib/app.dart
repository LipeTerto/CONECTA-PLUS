import 'package:material_ui/material_ui.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

/// Widget raiz do aplicativo.
class ConectaApp extends StatelessWidget {
  const ConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Conecta+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      // Idioma: português do Brasil (calendário, relógio, botões padrão).
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}