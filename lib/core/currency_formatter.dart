import 'package:intl/intl.dart';

final NumberFormat _fcfaFormat =
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

/// Utilitaire centralisé pour le formatage monétaire FCFA dans l'application.
class CurrencyFormatter {
  static NumberFormat get formatter => _fcfaFormat;

  static String format(num amount) => _fcfaFormat.format(amount);
}
