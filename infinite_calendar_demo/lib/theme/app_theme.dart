import 'package:flutter/material.dart';

const _surfaceContainer = Color(0xFFF4F6F8);
const _cardBackground = Color(0xFFFFFFFF);
const _primaryAccent = Color(0xFF1F1F1F);
const _todayDot = Color(0xFF101820);
const _outlineVariant = Color(0xFFE3E6EA);

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: _primaryAccent,
      onPrimary: Colors.white,
      surface: Colors.white,
      surfaceContainer: _surfaceContainer,
      surfaceContainerHighest: Colors.white,
      onSurface: Color(0xFF20232A),
      outlineVariant: _outlineVariant,
      secondary: Color(0xFF2B7FFF),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: _surfaceContainer,
    cardColor: _cardBackground,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: _surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _primaryAccent,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF1F1F1F),
      displayColor: const Color(0xFF1F1F1F),
    ),
    dividerColor: _outlineVariant,
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: _surfaceContainer,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: Color(0xFF0F1418),
      surfaceContainer: Color(0xFF1B232B),
      surfaceContainerHighest: Color(0xFF1B232B),
      onSurface: Colors.white,
      outlineVariant: Color(0xFF2E363E),
      secondary: Color(0xFF2B7FFF),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0F1418),
    cardColor: const Color(0xFF1B232B),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: const Color(0xFF0F1418),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: const Color(0xFF2E363E),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF1B232B),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}

Color todayIndicatorColor(Brightness brightness) {
  return brightness == Brightness.dark ? Colors.white : _todayDot;
}
