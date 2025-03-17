import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration with Neo-Brutalist style using green and black tones
class ThemeConfig {
  // Neo-Brutalist, green and black color palette for light theme
  static const Color primaryColorLight = Color(0xFF0F9D58); // Vibrant Green
  static const Color secondaryColorLight = Color(0xFF1E1E1E); // Rich Black
  static const Color accentColorLight = Color(0xFF4CAF50); // Lighter Green
  static const Color tertiaryColorLight = Color(0xFF2E7D32); // Forest Green
  static const Color errorColorLight = Color(0xFFD32F2F); // Bright Red
  static const Color successColorLight = Color(0xFF388E3C); // Medium Green
  static const Color warningColorLight = Color(0xFFFF9800); // Warm Orange
  static const Color infoColorLight = Color(0xFF0288D1); // Info Blue

  // Neo-Brutalist palette for dark theme - bolder versions
  static const Color primaryColorDark = Color(0xFF00E676); // Neon Green
  static const Color secondaryColorDark = Color(0xFF121212); // Deep Black
  static const Color accentColorDark = Color(0xFF69F0AE); // Bright Green
  static const Color tertiaryColorDark = Color(0xFF00C853); // Strong Green
  static const Color errorColorDark = Color(0xFFFF5252); // Bright Error Red
  static const Color successColorDark =
      Color(0xFF00E676); // Bright Success Green
  static const Color warningColorDark = Color(0xFFFFAB00); // Bright Warning
  static const Color infoColorDark = Color(0xFF40C4FF); // Bright Info

  // Background colors - brutalist contrast
  static const Color backgroundLight = Color(0xFFF5F5F5); // Off-White
  static const Color backgroundDark = Color(0xFF121212); // Deep Black

  // Card colors - high contrast for brutalist style
  static const Color cardLight = Color(0xFFFFFFFF); // Pure White
  static const Color cardDark = Color(0xFF1E1E1E); // Rich Black

  // Text colors - bold contrast for brutalist style
  static const Color textPrimaryLight = Color(0xFF000000); // Pure Black
  static const Color textSecondaryLight = Color(0xFF333333); // Dark Gray
  static const Color textTertiaryLight = Color(0xFF666666); // Medium Gray
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondaryDark = Color(0xFFCCCCCC); // Light Gray
  static const Color textTertiaryDark = Color(0xFF999999); // Medium Gray

  // Shadow colors for brutalist depth - more pronounced
  static const Color shadowLight = Color(0x50000000); // Strong Black Shadow
  static const Color shadowDark = Color(0x50000000); // Strong Black Shadow

  // Border colors - bold for brutalism
  static const Color borderLight = Color(0xFF000000); // Black Border
  static const Color borderDark = Color(0xFF00E676); // Neon Green Border

  /// Get light theme for the app
  static ThemeData getThemeLight() {
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      // Primary colors
      primaryColor: primaryColorLight,
      primaryColorDark: primaryColorLight.withOpacity(0.8),
      primaryColorLight: primaryColorLight.withOpacity(0.4),
      colorScheme: ColorScheme.light(
        primary: primaryColorLight,
        secondary: secondaryColorLight,
        tertiary: tertiaryColorLight,
        error: errorColorLight,
        background: backgroundLight,
        surface: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onBackground: textPrimaryLight,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),

      // Background
      scaffoldBackgroundColor: backgroundLight,

      // Material 3 support
      useMaterial3: true,

      // Cards - Neo-Brutalist style with thick borders and sharp corners
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 8,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderLight, width: 3),
        ),
        shadowColor: shadowLight,
      ),

      // App bar - Bold and stark
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryColorLight,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white, size: 28),
        actionsIconTheme: IconThemeData(color: Colors.white, size: 28),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),

      // Bottom app bar - Bold and consistent
      bottomAppBarTheme: BottomAppBarTheme(
        color: secondaryColorLight,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button - Chunky brutalist style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: secondaryColorLight, width: 3),
          ),
          foregroundColor: Colors.white,
          backgroundColor: primaryColorLight,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          shadowColor: shadowLight,
        ),
      ),

      // Text button - Bold typography
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          foregroundColor: primaryColorLight,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      // Outlined button - Chunky outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: secondaryColorLight, width: 3),
          foregroundColor: secondaryColorLight,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      // Input decoration - Brutalist sharp edges and thick borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderLight, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderLight, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColorLight, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: errorColorLight, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: errorColorLight, width: 3),
        ),
        labelStyle: TextStyle(
          color: textSecondaryLight,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        hintStyle: TextStyle(
          color: textTertiaryLight,
          fontWeight: FontWeight.normal,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        prefixIconColor: primaryColorLight,
        suffixIconColor: textSecondaryLight,
        floatingLabelStyle: TextStyle(
          color: primaryColorLight,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
      ),

      // Chip theme - Brutalist chunky style
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        disabledColor: Colors.grey[300]!,
        selectedColor: primaryColorLight,
        secondarySelectedColor: secondaryColorLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderLight, width: 2),
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryLight;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorLight;
          }
          return textSecondaryLight;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryLight;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorLight;
          }
          return textSecondaryLight;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryLight;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorLight;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryLight.withOpacity(.12);
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorLight.withOpacity(.5);
          }
          return textTertiaryLight.withOpacity(.4);
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColorLight,
        linearTrackColor: primaryColorLight.withOpacity(0.2),
        circularTrackColor: primaryColorLight.withOpacity(0.15),
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        indicatorColor: primaryColorLight,
        labelColor: primaryColorLight,
        unselectedLabelColor: textSecondaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        tileColor: Colors.transparent,
        selectedTileColor: primaryColorLight.withOpacity(0.1),
        iconColor: primaryColorLight,
        textColor: textPrimaryLight,
        dense: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        subtitleTextStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 24,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardLight,
        selectedItemColor: primaryColorLight,
        unselectedItemColor: textSecondaryLight,
        elevation: 8,
        enableFeedback: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text theme
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimaryLight,
          letterSpacing: -0.25,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: 0.15,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimaryLight,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimaryLight,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondaryLight,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight,
          letterSpacing: 0.5,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColorLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        extendedTextStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: cardLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.montserrat(
          fontSize: 16,
          color: textPrimaryLight,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        actionTextColor: accentColorLight,
      ),
    );
  }

  /// Get dark theme for the app
  static ThemeData getThemeDark() {
    final baseTheme = ThemeData.dark();

    return baseTheme.copyWith(
      // Primary colors
      primaryColor: primaryColorDark,
      primaryColorDark: primaryColorDark.withOpacity(0.8),
      primaryColorLight: primaryColorDark.withOpacity(0.4),
      colorScheme: ColorScheme.dark(
        primary: primaryColorDark,
        secondary: secondaryColorDark,
        tertiary: tertiaryColorDark,
        error: errorColorDark,
        background: backgroundDark,
        surface: cardDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onTertiary: Colors.black,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
        onError: Colors.black,
      ),

      // Background
      scaffoldBackgroundColor: backgroundDark,

      // Material 3 support
      useMaterial3: true,

      // Cards - Neo-Brutalist style with thick borders and sharp corners
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 8,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderDark, width: 3),
        ),
        shadowColor: shadowDark,
      ),

      // App bar - Bold and stark
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryColorDark,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black, size: 28),
        actionsIconTheme: IconThemeData(color: Colors.black, size: 28),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),

      // Bottom app bar - Bold and consistent
      bottomAppBarTheme: BottomAppBarTheme(
        color: secondaryColorDark,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button - Chunky brutalist style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: primaryColorDark, width: 3),
          ),
          foregroundColor: Colors.black,
          backgroundColor: primaryColorDark,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          shadowColor: shadowDark,
        ),
      ),

      // Text button - Bold typography
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          foregroundColor: primaryColorDark,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      // Outlined button - Chunky outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: primaryColorDark, width: 3),
          foregroundColor: primaryColorDark,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      // Input decoration - Brutalist sharp edges and thick borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderDark, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderDark, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColorDark, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: errorColorDark, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: errorColorDark, width: 3),
        ),
        labelStyle: TextStyle(
          color: textSecondaryDark,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        hintStyle: TextStyle(
          color: textTertiaryDark,
          fontWeight: FontWeight.normal,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        prefixIconColor: primaryColorDark,
        suffixIconColor: textSecondaryDark,
        floatingLabelStyle: TextStyle(
          color: primaryColorDark,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
      ),

      // Chip theme - Brutalist chunky style
      chipTheme: ChipThemeData(
        backgroundColor: backgroundDark,
        disabledColor: Colors.grey[700]!,
        selectedColor: primaryColorDark,
        secondarySelectedColor: secondaryColorDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderDark, width: 2),
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryDark;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorDark;
          }
          return textSecondaryDark;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryDark;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorDark;
          }
          return textSecondaryDark;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryDark;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorDark;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textTertiaryDark.withOpacity(.12);
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColorDark.withOpacity(.5);
          }
          return textTertiaryDark.withOpacity(.4);
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColorDark,
        linearTrackColor: primaryColorDark.withOpacity(0.2),
        circularTrackColor: primaryColorDark.withOpacity(0.15),
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        indicatorColor: primaryColorDark,
        labelColor: primaryColorDark,
        unselectedLabelColor: textSecondaryDark,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        tileColor: Colors.transparent,
        selectedTileColor: primaryColorDark.withOpacity(0.1),
        iconColor: primaryColorDark,
        textColor: textPrimaryDark,
        dense: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        subtitleTextStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 24,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardDark,
        selectedItemColor: primaryColorDark,
        unselectedItemColor: textSecondaryDark,
        elevation: 8,
        enableFeedback: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text theme
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
          letterSpacing: -0.25,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimaryDark,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimaryDark,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondaryDark,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryDark,
          letterSpacing: 0.5,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColorDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        extendedTextStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: cardDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.montserrat(
          fontSize: 16,
          color: textPrimaryDark,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryDark,
        contentTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        actionTextColor: accentColorDark,
      ),
    );
  }
}
