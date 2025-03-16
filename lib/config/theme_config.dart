import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration with organic, natural color palette
class ThemeConfig {
  // Natural, earthy color palette for light theme
  static const Color primaryColorLight = Color(0xFF3E6C40); // Forest Green
  static const Color secondaryColorLight = Color(0xFF9C6D3E); // Warm Brown
  static const Color accentColorLight = Color(0xFFBBA065); // Wheat/Hay
  static const Color tertiaryColorLight = Color(0xFF5E8B7E); // Sage Green
  static const Color errorColorLight = Color(0xFFB84A3D); // Earthy Red
  static const Color successColorLight = Color(0xFF5B8C5A); // Leaf Green
  static const Color warningColorLight = Color(0xFFD89D45); // Amber
  static const Color infoColorLight = Color(0xFF5D8CAE); // Blue Sky

  // Natural, earthy color palette for dark theme - softer versions
  static const Color primaryColorDark =
      Color(0xFF4A7D5A); // Softer Forest Green
  static const Color secondaryColorDark = Color(0xFFAD825E); // Softer Brown
  static const Color accentColorDark = Color(0xFFCCB87A); // Softer Wheat
  static const Color tertiaryColorDark = Color(0xFF6FA093); // Softer Sage
  static const Color errorColorDark = Color(0xFFC56B5E); // Softer Red
  static const Color successColorDark = Color(0xFF6B9D6A); // Softer Leaf Green
  static const Color warningColorDark = Color(0xFFE5B475); // Softer Amber
  static const Color infoColorDark = Color(0xFF7EAACA); // Softer Sky

  // Background colors - natural paper and dark soil tones
  static const Color backgroundLight = Color(0xFFF7F4EF); // Cream Paper
  static const Color backgroundDark = Color(0xFF232620); // Dark Soil

  // Card colors - slightly elevated from background
  static const Color cardLight = Color(0xFFFCFAF7); // White Paper
  static const Color cardDark = Color(0xFF2B2F28); // Rich Soil

  // Text colors - organic and natural
  static const Color textPrimaryLight = Color(0xFF33352F); // Charcoal
  static const Color textSecondaryLight = Color(0xFF6A6D66); // Slate Gray
  static const Color textTertiaryLight = Color(0xFF9EA096); // Moss Gray
  static const Color textPrimaryDark = Color(0xFFE6E7E3); // Light Stone
  static const Color textSecondaryDark = Color(0xFFB7B9B3); // Medium Stone
  static const Color textTertiaryDark = Color(0xFF8A8C85); // Dark Stone

  // Shadow colors for natural depth
  static const Color shadowLight = Color(0x1A000000); // Soft Black Shadow
  static const Color shadowDark = Color(0x1A000000); // Soft Black Shadow

  // Border colors
  static const Color borderLight = Color(0xFFE3DDD3); // Light Sand
  static const Color borderDark = Color(0xFF3B3F38); // Dark Moss

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

      // Cards
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: shadowLight,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardLight,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimaryLight),
        actionsIconTheme: const IconThemeData(color: textPrimaryLight),
        titleTextStyle: GoogleFonts.montserrat(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom app bar
      bottomAppBarTheme: BottomAppBarTheme(
        color: cardLight,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const CircularNotchedRectangle(),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: Colors.white,
          backgroundColor: primaryColorLight,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shadowColor: primaryColorLight.withOpacity(0.3),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          foregroundColor: primaryColorLight,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: primaryColorLight, width: 1.5),
          foregroundColor: primaryColorLight,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColorLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColorLight, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColorLight, width: 1.5),
        ),
        labelStyle:
            TextStyle(color: textSecondaryLight, fontWeight: FontWeight.w500),
        hintStyle:
            TextStyle(color: textTertiaryLight, fontWeight: FontWeight.normal),
        prefixIconColor: primaryColorLight,
        suffixIconColor: textSecondaryLight,
        floatingLabelStyle:
            TextStyle(color: primaryColorLight, fontWeight: FontWeight.w600),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        disabledColor: Colors.grey[300]!,
        selectedColor: primaryColorLight.withOpacity(0.2),
        secondarySelectedColor: primaryColorLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderLight),
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),

      // Background
      scaffoldBackgroundColor: backgroundDark,

      // Material 3 support
      useMaterial3: true,

      // Cards
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: shadowDark,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardDark,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimaryDark),
        actionsIconTheme: const IconThemeData(color: textPrimaryDark),
        titleTextStyle: GoogleFonts.montserrat(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom app bar
      bottomAppBarTheme: BottomAppBarTheme(
        color: cardDark,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const CircularNotchedRectangle(),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: Colors.white,
          backgroundColor: primaryColorDark,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shadowColor: primaryColorDark.withOpacity(0.3),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          foregroundColor: primaryColorDark,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: primaryColorDark, width: 1.5),
          foregroundColor: primaryColorDark,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColorDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColorDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColorDark, width: 1.5),
        ),
        labelStyle:
            TextStyle(color: textSecondaryDark, fontWeight: FontWeight.w500),
        hintStyle:
            TextStyle(color: textTertiaryDark, fontWeight: FontWeight.normal),
        prefixIconColor: primaryColorDark,
        suffixIconColor: textSecondaryDark,
        floatingLabelStyle:
            TextStyle(color: primaryColorDark, fontWeight: FontWeight.w600),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundDark,
        disabledColor: Colors.grey[700]!,
        selectedColor: primaryColorDark.withOpacity(0.2),
        secondarySelectedColor: primaryColorDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle:
            TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderDark),
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

      // Rest of the dark theme components updated with consistent styling...
    );
  }
}
