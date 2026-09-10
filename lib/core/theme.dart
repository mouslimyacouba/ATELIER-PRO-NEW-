import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette du 2e design system "AtelierPro" généré sur Stitch — mode sombre
/// "Tactile Modernism / High-Contrast Dark Elegance", pensé pour la
/// lisibilité en plein soleil et en atelier peu éclairé. Remplace la
/// première version claire (espresso/ocre). Les noms historiques
/// (terracotta, sable, encre...) sont conservés pour éviter de retoucher
/// chaque écran, mais pointent désormais vers les nouvelles valeurs.
class AtelierProColors {
  // --- Marque ---
  static const primary = Color(0xFFFF6B00); // Orange "sécurité atelier" — CTA, FAB, actifs
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFFBAC7E1);
  static const tertiary = Color(0xFF4EDEA3); // Vert menthe — état "livré"

  // --- Surfaces (mode sombre) ---
  static const surface = Color(0xFF070E18); // fond général (surface-base)
  static const surfaceContainerLow = Color(0xFF0B1B35);
  static const surfaceContainer = Color(0xFF0F223D); // cartes standard (surface-card)
  static const surfaceContainerHigh = Color(0xFF172E4F); // modales, feuilles (surface-elevated)
  static const surfaceHighlight = Color(0xFF1E3B64);
  static const onSurface = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFFCBD5E1); // texte secondaire
  static const onSurfaceMuted = Color(0xFF64748B); // texte tertiaire/désactivé
  static const outlineVariant = Color(0xFF1B3356); // bordures fines

  // --- Statuts de commande ---
  static const statusPending = Color(0xFFF59E0B); // en_attente
  static const statusProgress = Color(0xFF38BDF8); // en_cours
  static const statusDone = Color(0xFF10B981); // termine
  static const statusDelivered = Color(0xFF4EDEA3); // livre
  static const statusUrgent = Color(0xFFEF4444); // retards, alertes

  static const whatsappGreen = Color(0xFF25D366);

  // --- Alias historiques (compat avec les écrans existants) ---
  static const terracotta = primary;
  static const sable = surface;
  static const encre = onSurface;
  static const vertSucces = statusDone;
  static const orangeAttente = statusPending;
  static const rougeAlerte = statusUrgent;
  static const secondaryContainer = Color(0xFF3D4A5F); // pastille active nav
}

class AtelierProTheme {
  /// Le design system "AtelierPro" v2 est mono-police (Outfit), y compris
  /// pour les titres — plus de séparation Hanken/Source Sans comme avant.
  static TextTheme get _textTheme {
    final base = GoogleFonts.outfitTextTheme().apply(
      bodyColor: AtelierProColors.onSurface,
      displayColor: AtelierProColors.onSurface,
    );
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.02),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Style pour les montants FCFA (`currency-display` du design system) —
  /// à utiliser explicitement là où ça a du sens (totaux, soldes), pas
  /// comme police globale.
  static TextStyle dataStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.w700, Color? color}) =>
      GoogleFonts.outfit(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: -0.01);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AtelierProColors.primary,
        brightness: Brightness.dark,
        primary: AtelierProColors.primary,
        onPrimary: AtelierProColors.onPrimary,
        secondary: AtelierProColors.secondary,
        tertiary: AtelierProColors.tertiary,
        surface: AtelierProColors.surface,
        onSurface: AtelierProColors.onSurface,
        error: AtelierProColors.statusUrgent,
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
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AtelierProColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AtelierProColors.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AtelierProColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AtelierProColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtelierProColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AtelierProColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AtelierProColors.onSurface,
          side: const BorderSide(color: AtelierProColors.outlineVariant, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AtelierProColors.primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtelierProColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AtelierProColors.onSurfaceVariant),
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: AtelierProColors.onSurfaceMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AtelierProColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: AtelierProColors.surfaceContainer,
        side: const BorderSide(color: AtelierProColors.outlineVariant),
      ),
      dividerTheme: const DividerThemeData(color: AtelierProColors.outlineVariant, thickness: 1),
      iconTheme: const IconThemeData(color: AtelierProColors.onSurface),
      listTileTheme: const ListTileThemeData(
        iconColor: AtelierProColors.onSurfaceVariant,
        textColor: AtelierProColors.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AtelierProColors.surfaceContainer,
        indicatorColor: AtelierProColors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? AtelierProColors.primary : AtelierProColors.onSurfaceMuted,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AtelierProColors.surfaceContainerHigh,
        textStyle: GoogleFonts.outfit(color: AtelierProColors.onSurface, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AtelierProColors.surfaceContainerHigh,
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AtelierProColors.onSurface),
        contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: AtelierProColors.onSurfaceVariant),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AtelierProColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AtelierProColors.surfaceContainerHigh,
        contentTextStyle: GoogleFonts.outfit(color: AtelierProColors.onSurface),
      ),
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
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
