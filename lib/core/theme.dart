import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette issue du design system "Atelier Artisanat" généré sur Stitch
/// (stitch.withgoogle.com), conservée comme identité visuelle de l'app.
/// Les noms historiques (terracotta, sable, encre...) sont conservés pour
/// éviter de retoucher chaque écran, mais pointent désormais vers les
/// vraies valeurs du design system.
class AtelierProColors {
  // --- Couleurs de marque ---
  static const primary = Color(0xFF442A22); // Espresso — boutons, FAB, actions clés
  static const primaryContainer = Color(0xFF5D4037);
  static const secondary = Color(0xFF745B20); // Ocre — accents "craft"
  static const secondaryContainer = Color(0xFFFFDB94); // pastille active (nav, highlights)
  static const tertiary = Color(0xFF093258); // Bleu — administratif / financier

  // --- Surfaces ---
  static const surface = Color(0xFFFFF8F6);
  static const surfaceContainerLow = Color(0xFFFAF2F0);
  static const surfaceContainer = Color(0xFFF4ECEA);
  static const surfaceContainerHigh = Color(0xFFEFE6E4);
  static const onSurface = Color(0xFF1E1B1A);
  static const onSurfaceVariant = Color(0xFF504441);
  static const outlineVariant = Color(0xFFD4C3BE);

  // --- Statuts de commande ---
  static const statusPending = Color(0xFFF59E0B); // en_attente
  static const statusProgress = Color(0xFF3B82F6); // en_cours
  static const statusDone = Color(0xFF10B981); // termine
  static const statusDelivered = Color(0xFF6366F1); // livre

  // --- Alias historiques (compat avec les écrans existants) ---
  static const terracotta = primary;
  static const sable = surface;
  static const encre = onSurface;
  static const vertSucces = statusDone;
  static const orangeAttente = statusPending;
  static const rougeAlerte = Color(0xFFBA1A1A);
}

class AtelierProTheme {
  static TextTheme get _textTheme {
    final headline = GoogleFonts.hankenGroteskTextTheme();
    final body = GoogleFonts.sourceSans3TextTheme();
    return body.copyWith(
      headlineLarge: headline.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      headlineMedium: headline.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: headline.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: headline.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: headline.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: headline.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Police "données" (JetBrains Mono) pour les montants, mesures et labels
  /// techniques — à utiliser explicitement là où ça a du sens (chiffres,
  /// fiches de mesures), pas comme police globale.
  static TextStyle dataStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.w600, Color? color}) =>
      GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AtelierProColors.primary,
        brightness: Brightness.light,
        primary: AtelierProColors.primary,
        secondary: AtelierProColors.secondary,
        tertiary: AtelierProColors.tertiary,
        surface: AtelierProColors.surface,
        error: AtelierProColors.rougeAlerte,
      ),
      scaffoldBackgroundColor: AtelierProColors.surface,
      textTheme: _textTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AtelierProColors.surface,
        foregroundColor: AtelierProColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AtelierProColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtelierProColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AtelierProColors.onSurface,
          side: const BorderSide(color: AtelierProColors.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AtelierProColors.primary,
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtelierProColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AtelierProColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: AtelierProColors.onSurfaceVariant),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AtelierProColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: AtelierProColors.surfaceContainer,
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(color: AtelierProColors.outlineVariant, thickness: 1),
    );
  }
}

/// Petit badge "pill" pour les statuts, avec le point coloré caractéristique
/// du design system Stitch (voir Components > Chips).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
