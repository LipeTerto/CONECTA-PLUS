import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget raiz do aplicativo.
/// StatelessWidget = widget sem estado interno que muda.
class ConectaApp extends StatelessWidget {
  const ConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conecta+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B4FBF)),
      ),
      // Idioma: português do Brasil (calendário, relógio, botões padrão).
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SetupCheckScreen(),
    );
  }
}

/// TELA TEMPORÁRIA: só serve para confirmar que o app fala com o Supabase.
/// StatefulWidget = widget cujo estado muda (aqui: carregando / resultado).
class SetupCheckScreen extends StatefulWidget {
  const SetupCheckScreen({super.key});

  @override
  State<SetupCheckScreen> createState() => _SetupCheckScreenState();
}

class _SetupCheckScreenState extends State<SetupCheckScreen> {
  bool _loading = false;
  String? _result;

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    String message;
    try {
      // Tenta logar com credenciais falsas. Se o servidor responder
      // "credenciais inválidas", é porque a URL e a chave estão corretas.
      await Supabase.instance.client.auth.signInWithPassword(
        email: 'teste@example.com',
        password: 'senha-invalida-123',
      );
      message = 'Resposta inesperada: o login foi aceito.';
    } on AuthException catch (e) {
      message = 'O servidor respondeu: ${e.message}';
    } catch (e) {
      message = 'Falha de conexão: $e';
    }

    // Se a tela foi fechada durante a espera, não atualize nada.
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conecta+ | Teste de conexão')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Toque no botão para testar a conexão com o Supabase.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _testConnection,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Testar conexão'),
              ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                Text(_result!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}