import 'package:url_launcher/url_launcher.dart';

/// Normalise un numéro nigérien pour l'international : ajoute l'indicatif
/// +227 si le numéro local (8 chiffres) ne l'a pas déjà. Reste permissif
/// pour les numéros déjà internationaux (garde tel quel si >8 chiffres).
/// Public (pas de préfixe `_`) pour être réutilisée par l'auth téléphone.
String normalizePhone(String raw) {
  // Supprime tout ce qui n'est pas chiffre ou +
  final clean = raw.replaceAll(RegExp(r'[^0-9+]'), '');

  if (clean.startsWith('+')) return clean;

  // Cas spécifique du Niger (8 chiffres locaux)
  final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length == 8) return '+227$digitsOnly';

  // Si commence déjà par 227 sans le +
  if (digitsOnly.startsWith('227') && digitsOnly.length == 11) {
    return '+$digitsOnly';
  }

  return clean.isEmpty ? '' : '+$clean';
}

Future<void> callPhone(String rawPhone) async {
  final phone = normalizePhone(rawPhone);
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}

Future<void> openWhatsApp(String rawPhone, {String? message}) async {
  final phone = normalizePhone(rawPhone).replaceAll('+', '');
  final text = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
  final uri = Uri.parse('https://wa.me/$phone$text');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
