import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global theme mode notifier shared by every screen's toggle button
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.dark,
);

// Switches between light and dark mode
void toggleTheme() {
  themeModeNotifier.value = themeModeNotifier.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

class AppColors {
  final Color espresso;
  final Color espressoDark;
  final Color latte;
  final Color oat;
  final Color cinnamon;
  final Color gold;
  final Color line;

  const AppColors({
    required this.espresso,
    required this.espressoDark,
    required this.latte,
    required this.oat,
    required this.cinnamon,
    required this.gold,
    required this.line,
  });

  // Color palette used for the light theme
  static const light = AppColors(
    espresso: Color(0xFFFAF3E7),
    espressoDark: Color(0xFFFFFFFF),
    latte: Color(0xFF2A1B12),
    oat: Color(0xFF8A7259),
    cinnamon: Color(0xFFB9652E),
    gold: Color(0xFFAD7A22),
    line: Color(0xFFDDCBB3),
  );

  // Color palette used for the dark theme
  static const dark = AppColors(
    espresso: Color(0xFF1B110D),
    espressoDark: Color(0xFF2C1D15),
    latte: Color(0xFFF1E4D5),
    oat: Color(0xFFB8A18B),
    cinnamon: Color(0xFFE48A45),
    gold: Color(0xFFDDAA45),
    line: Color(0xFF493629),
  );

  // Returns the appropriate color palette based on the current theme
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

// Builds the app's light or dark ThemeData using the selected color palette
ThemeData buildAppTheme(AppColors palette, Brightness brightness) {
  final textTheme = GoogleFonts.manropeTextTheme(
    brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: palette.espresso,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.cinnamon,
      brightness: brightness,
      surface: palette.espresso,
    ),
    textTheme: textTheme.apply(
      bodyColor: palette.latte,
      displayColor: palette.latte,
    ),
  );
}
