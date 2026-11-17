import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

/// Formatação de datas e horários para exibição.
class Formatters {
  Formatters._();

  /// 20/12/2026
  static String date(DateTime value) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(value);

  /// Domingo, 20 de dezembro de 2026
  static String longDate(DateTime value) {
    final text = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(value);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// 19:30
  static String time(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}