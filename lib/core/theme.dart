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

  // --- surfaces & Conteneurs (Mode Albâtre Clair) ---
  static const surface = Color(0xFFFAF8FF); // Canvas de fond principal (anti-éblouissement)
  static const surfaceDim = Color(0xFFD2D9F4);
  static const surfaceBright = Color(0xFFFAF8FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF); // Cartes & Inputs
  static const surfaceContainerLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceContainerHigh = Color(0xFFE2E7FF); // Modales & Bottom Sheets
  static const surfaceContainerHighest = Color(0xFFDAE2FD);

  // --- Surfaces & Conteneurs (Mode Nuit Profonde) ---
  static const surfaceDark = Color(0xFF0B1220); // Fond sombre indigo
  static const surfaceDimDark = Color(0xFF050B18);
  static const surfaceBrightDark = Color(0xFF1E2638);
  static const surfaceContainerLowestDark = Color(0xFF020408);
  static const surfaceContainerLowDark = Color(0xFF131B2E);
  static const surfaceContainerDark = Color(0xFF1E2638); // Cartes en mode sombre
  static const surfaceContainerHighDark = Color(0xFF28324D);
  static const surfaceContainerHighestDark = Color(0xFF333E5D);

  static const onSurface = Color(0xFF131B2E); // Encre noire haute densité
  static const onSurfaceDark = Color(0xFFE2E7FF); // Texte clair
  static const onSurfaceVariant = Color(0xFF43474F); // Métadonnées & sous-titres
  static const onSurfaceVariantDark = Color(0xFFC3C6D0);
  static const onSurfaceMuted = Color(0xFF747780); // Texte désactivé
  static const onSurfaceMutedDark = Color(0xFF8E9199);

  static const outline = Color(0xFF747780);
  static const outlineDark = Color(0xFF8E9199);
  static const outlineVariant = Color(0xFFC3C6D0); // Bordures fines de précision
  static const outlineVariantDark = Color(0xFF43474F);

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
  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AtelierProColors.onSurface : AtelierProColors.onSurfaceDark;
    final base = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: color,
      displayColor: color,
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
  static TextStyle currencyDisplayStyle({double fontSize = 22, FontWeight fontWeight = FontWeight.w800, Color? color, Brightness brightness = Brightness.light}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? (brightness == Brightness.light ? AtelierProColors.primary : AtelierProColors.onSurfaceDark),
        letterSpacing: -0.44,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Alias de compatibilité pour les écrans existants
  static TextStyle dataStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.w700, Color? color, Brightness brightness = Brightness.light}) =>
      currencyDisplayStyle(fontSize: fontSize, fontWeight: fontWeight, color: color, brightness: brightness);


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
      textTheme: _textTheme(Brightness.light),
    );

    return _applyCommonTheme(base, Brightness.light);
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AtelierProColors.primary,
        brightness: Brightness.dark,
        primary: AtelierProColors.primaryFixed, // Utilisation d'une variante plus claire
        onPrimary: AtelierProColors.primary,
        primaryContainer: AtelierProColors.primaryContainer,
        onPrimaryContainer: AtelierProColors.onPrimaryContainer,
        secondary: AtelierProColors.secondaryFixedDim,
        onSecondary: AtelierProColors.onSecondaryContainer,
        secondaryContainer: AtelierProColors.secondaryContainer,
        onSecondaryContainer: Colors.white,
        tertiary: AtelierProColors.tertiaryFixedDim,
        onTertiary: AtelierProColors.tertiaryContainer,
        surface: AtelierProColors.surfaceDark,
        onSurface: AtelierProColors.onSurfaceDark,
        error: AtelierProColors.statusUrgent,
      ),
      scaffoldBackgroundColor: AtelierProColors.surfaceDark,
      textTheme: _textTheme(Brightness.dark),
    );

    return _applyCommonTheme(base, Brightness.dark);
  }

  static ThemeData _applyCommonTheme(ThemeData base, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final surfaceColor = isLight ? AtelierProColors.surfaceContainerLowest : AtelierProColors.surfaceContainerDark;
    final onSurfaceColor = isLight ? AtelierProColors.onSurface : AtelierProColors.onSurfaceDark;
    final outlineColor = isLight ? AtelierProColors.outlineVariant : AtelierProColors.outlineVariantDark;

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AtelierProColors.surfaceContainerLowest : AtelierProColors.surfaceDark,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isLight ? AtelierProColors.primary : AtelierProColors.onSurfaceDark,
        ),
        iconTheme: IconThemeData(color: isLight ? AtelierProColors.primary : AtelierProColors.onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outlineColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLight ? AtelierProColors.primaryContainer : AtelierProColors.primaryFixed,
          foregroundColor: isLight ? Colors.white : AtelierProColors.primary,
          disabledBackgroundColor: (isLight ? AtelierProColors.primaryContainer : AtelierProColors.primaryFixed).withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isLight ? AtelierProColors.primary : AtelierProColors.onSurfaceDark,
          side: BorderSide(color: outlineColor, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isLight ? AtelierProColors.secondaryContainer : AtelierProColors.secondaryFixedDim,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isLight ? AtelierProColors.primaryContainer : AtelierProColors.primaryFixed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AtelierProColors.statusUrgent, width: 1),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: isLight ? AtelierProColors.onSurfaceVariant : AtelierProColors.onSurfaceVariantDark),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: isLight ? AtelierProColors.onSurfaceMuted : AtelierProColors.onSurfaceMutedDark),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AtelierProColors.secondaryContainer,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9999))),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: surfaceColor,
        side: BorderSide(color: outlineColor),
      ),
      dividerTheme: DividerThemeData(color: outlineColor, thickness: 1),
      iconTheme: IconThemeData(color: onSurfaceColor),
      listTileTheme: ListTileThemeData(
        iconColor: isLight ? AtelierProColors.onSurfaceVariant : AtelierProColors.onSurfaceVariantDark,
        textColor: onSurfaceColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: AtelierProColors.secondaryContainer.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? (isLight ? AtelierProColors.secondaryContainer : AtelierProColors.secondaryFixedDim)
                : (isLight ? AtelierProColors.onSurfaceMuted : AtelierProColors.onSurfaceMutedDark),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        textStyle: GoogleFonts.plusJakartaSans(color: onSurfaceColor, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: onSurfaceColor),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: isLight ? AtelierProColors.onSurfaceVariant : AtelierProColors.onSurfaceVariantDark),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AtelierProColors.primaryContainer : AtelierProColors.surfaceContainerHighDark,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: isLight ? Colors.white : AtelierProColors.onSurfaceDark),
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

