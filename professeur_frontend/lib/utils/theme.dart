import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════
  //  PALETTE BLEU NUIT ROYALE — "In God We Trust"
  // ═══════════════════════════════════════════════

  // Bleus nuit principaux
  static const Color bgDeep    = Color(0xFF060D1F); // Fond ultra-profond
  static const Color bgDark    = Color(0xFF0D1B3E); // Fond principal
  static const Color bgMedium  = Color(0xFF122251); // Fond medium
  static const Color primary   = Color(0xFF1A237E); // Bleu nuit royal
  static const Color primaryLight = Color(0xFF283593);
  static const Color primaryDark  = Color(0xFF0D1B3E);

  // Surfaces dark
  static const Color surface       = Color(0xFF152047); // Card surface
  static const Color surfaceLight  = Color(0xFF1C2D5E); // Card légère
  static const Color surfaceBorder = Color(0xFF243570); // Bordure subtile

  // Accent doré "In God We Trust"
  static const Color gold        = Color(0xFFFFD700);
  static const Color goldLight   = Color(0xFFFFE566);
  static const Color goldDark    = Color(0xFFFFA500);
  static const Color accent      = Color(0xFFFFD700);

  // Couleurs sémantiques
  static const Color success  = Color(0xFF10B981);
  static const Color error    = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF38BDF8);
  static const Color secondary = Color(0xFF38BDF8);

  // Texte sur fond sombre
  static const Color textPrimary   = Color(0xFFF1F5FF);
  static const Color textSecondary = Color(0xFF8FA3C8);
  static const Color textMuted     = Color(0xFF4A6080);

  // Alias de compatibilité (backward compat)
  static const Color background  = bgDark;
  static const Color bgDarkAlias = bgDark;
  static const Color borderDark  = surfaceBorder;
  static const Color emerald     = success;

  // Slogan officiel
  static const String slogan = 'In God We Trust';
  static const String schoolName = 'Notre Dame Toutes Grâces';

  // ═══════════════════════════════════════════════
  //  GRADIENTS
  // ═══════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B3E), Color(0xFF1A237E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF060D1F), Color(0xFF0D1B3E), Color(0xFF1A237E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE566), Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF152047), Color(0xFF1C2D5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1C2D5E), Color(0xFF152047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF0D1B3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGlow = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════
  //  SHADOWS
  // ═══════════════════════════════════════════════

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: const Color(0xFF1A237E).withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: gold.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ═══════════════════════════════════════════════
  //  THEME DATA
  // ═══════════════════════════════════════════════

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: bgDark,
      tertiary: info,
      onTertiary: bgDark,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceLight,
      outline: surfaceBorder,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,

      // Typographie premium
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w800, color: textPrimary),
        displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: textPrimary),
        headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: textPrimary, fontSize: 20),
        titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: textPrimary, fontSize: 16),
        titleSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: textSecondary, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: textMuted, fontSize: 12),
        labelLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w700, letterSpacing: 0.5, color: textPrimary),
        labelMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: textSecondary),
        labelSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.8),
      ),

      // Cards — fond surface sombre
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),

      // Inputs dark premium
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(
            color: gold, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // Boutons principal
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: surfaceBorder, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // AppBar dark
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgDark,
        selectedItemColor: gold,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialogs dark
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: surfaceBorder),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // Chips dark
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primary,
        labelStyle: const TextStyle(
            color: textPrimary, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(
            color: gold, fontWeight: FontWeight.bold),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: surfaceBorder,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // CheckBox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(bgDark),
        side: const BorderSide(color: textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected))
            return gold.withOpacity(0.3);
          return surfaceLight;
        }),
      ),
    );
  }
}
