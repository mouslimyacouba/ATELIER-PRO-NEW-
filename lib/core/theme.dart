import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System "Sahara Craft Tech" — Tactile Modernist
/// Palette et typographie pour l'application AtelierPro (Niger).
class AtelierProColors {
  // --- Marque ---
  static const primary = Color(0xFF001F41); // Indigo Océanique Profond
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFF0F3460); // Navy de structure
  static const onPrimaryContainer = Color(0xFF7F9DD0);

  static const secondary = Color(0xFFA83900); // Terracotta / Ambre
  static const onSecondary = Colors.white;
  static const secondaryContainer = Color(0xFFFC6018); // Accent vif FAB / CTA
  static const onSecondaryContainer = Color(0xFF531800);
  static const secondaryFixed = Color(0xFFFFDBCF);
  static const secondaryFixedDim = Color(0xFFFFB59A);
  static const primaryFixed = Color(0xFFD5E3FF);
  static const tertiaryFixedDim = Color(0xFF4EDEA3);

  static const tertiary = Color(0xFF002416); // Vert sombre de réglage
  static const onTertiary = Colors.white;
  static const tertiaryContainer = Color(0xFF003C27);
  static const onTertiaryContainer = Color(0xFF00B27B); // Vert opérationnel réglé

  // --- Surfaces & Conteneurs (Mode Albâtre Clair) ---
  static const surface = Color(0xFFFAF8FF); // Canvas de fond principal (anti-éblouissement)
  static const surfaceDim = Color(0xFFD2D9F4);
  static const surfaceBright = Color(0xFFFAF8FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF); // Cartes & Inputs
  static const surfaceContainerLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceContainerHigh = Color(0xFFE2E7FF); // Modales & Bottom Sheets
  static const surfaceContainerHighest = Color(0xFFDAE2FD);

  static const onSurface = Color(0xFF131B2E); // Encre noire haute densité
  static const onSurfaceVariant = Color(0xFF43474F); // Métadonnées & sous-titres
  static const onSurfaceMuted = Color(0xFF747780); // Texte désactivé
  static const outline = Color(0xFF747780);
  static const outlineVariant = Color(0xFFC3C6D0); // Bordures fines de précision

  // --- Statuts de commande ---
  static const statusPending = Color(0xFFFC6018); // En attente / Acompte versé
  static const statusProgress = Color(0xFF0F3460); // En cours de fabrication
  static const statusDone = Color(0xFF10B981); // Terminé / Prêt
  static const statusDelivered = Color(0xFF00B27B); // Livré
  static const statusUrgent = Color(0xFFBA1A1A); // Retards, alertes

  static const whatsappGreen = Color(0xFF25D366);

  // --- Alias historiques (compatibilité avec le code existant) ---
  static const terracotta = secondaryContainer;
  static const sable = surface;
  static const encre = onSurface;
  static const vertSucces = statusDone;
  static const orangeAttente = statusPending;
  static const rougeAlerte = statusUrgent;
}

class AtelierProTheme {
  /// Typographie basée sur Plus Jakarta Sans
  static TextTheme get _textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: AtelierProColors.onSurface,
      displayColor: AtelierProColors.onSurface,
    );
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 32, height: 1.25, letterSpacing: -0.64),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 24, height: 1.33, letterSpacing: -0.24),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 20, height: 1.4),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18, height: 1.33),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 16, height: 1.38),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400, fontSize: 16, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 14, height: 1.43),
      bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400, fontSize: 12, height: 1.33),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13, height: 1.38, letterSpacing: 0.13),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 11, height: 1.27, letterSpacing: 0.44),
    );
  }

  /// Formatage numérique spécial pour les montants FCFA (`currency-display`)
  static TextStyle currencyDisplayStyle({double fontSize = 22, FontWeight fontWeight = FontWeight.w800, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AtelierProColors.primary,
        letterSpacing: -0.44,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Alias de compatibilité pour les écrans existants
  static TextStyle dataStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.w700, Color? color}) =>
      currencyDisplayStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);


  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AtelierProColors.primary,
        brightness: Brightness.light,
        primary: AtelierProColors.primary,
        onPrimary: AtelierProColors.onPrimary,
        primaryContainer: AtelierProColors.primaryContainer,
        onPrimaryContainer: AtelierProColors.onPrimaryContainer,
        secondary: AtelierProColors.secondary,
        onSecondary: AtelierProColors.onSecondary,
        secondaryContainer: AtelierProColors.secondaryContainer,
        onSecondaryContainer: AtelierProColors.onSecondaryContainer,
        tertiary: AtelierProColors.tertiary,
        onTertiary: AtelierProColors.onTertiary,
        tertiaryContainer: AtelierProColors.tertiaryContainer,
        onTertiaryContainer: AtelierProColors.onTertiaryContainer,
        surface: AtelierProColors.surface,
        onSurface: AtelierProColors.onSurface,
        error: AtelierProColors.statusUrgent,
      ),
      scaffoldBackgroundColor: AtelierProColors.surface,
      textTheme: _textTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AtelierProColors.surfaceContainerLowest,
        foregroundColor: AtelierProColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AtelierProColors.primary,
        ),
        iconTheme: const IconThemeData(color: AtelierProColors.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AtelierProColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtelierProColors.primaryContainer,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AtelierProColors.primaryContainer.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AtelierProColors.primary,
          side: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AtelierProColors.secondaryContainer,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtelierProColors.surfaceContainerLowest,
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
          borderSide: const BorderSide(color: AtelierProColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AtelierProColors.statusUrgent, width: 1),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AtelierProColors.onSurfaceVariant),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AtelierProColors.onSurfaceMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AtelierProColors.secondaryContainer,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9999))),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: AtelierProColors.surfaceContainerLowest,
        side: const BorderSide(color: AtelierProColors.outlineVariant),
      ),
      dividerTheme: const DividerThemeData(color: AtelierProColors.outlineVariant, thickness: 1),
      iconTheme: const IconThemeData(color: AtelierProColors.onSurface),
      listTileTheme: const ListTileThemeData(
        iconColor: AtelierProColors.onSurfaceVariant,
        textColor: AtelierProColors.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AtelierProColors.surfaceContainerLowest,
        indicatorColor: AtelierProColors.secondaryContainer.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? AtelierProColors.secondaryContainer : AtelierProColors.onSurfaceMuted,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AtelierProColors.surfaceContainerLowest,
        textStyle: GoogleFonts.plusJakartaSans(color: AtelierProColors.onSurface, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AtelierProColors.surfaceContainerLowest,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AtelierProColors.onSurface),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AtelierProColors.onSurfaceVariant),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AtelierProColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AtelierProColors.primaryContainer,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
      ),
    );
  }
}

/// Badge "pill" interactif pour les statuts
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

