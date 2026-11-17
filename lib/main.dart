import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  // Necessário quando se executa código assíncrono antes do runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega os nomes de meses e dias em português (usado pelo intl).
  await initializeDateFormatting('pt_BR');

  // Conecta o app ao seu projeto Supabase. O parâmetro se chama anonKey
  // por histórico, mas aceita a publishable key.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );

  runApp(const ConectaApp());
}