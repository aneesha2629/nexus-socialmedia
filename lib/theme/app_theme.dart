import 'package:flutter/material.dart';

class T {
  static const primary = Color(0xFF6C63FF);
  static const accent  = Color(0xFFFF6B9D);
  static const green   = Color(0xFF22C55E);

  static const List<Color> avatarColors = [
    Color(0xFF6C63FF), Color(0xFFFF6B9D), Color(0xFF22C55E),
    Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF06B6D4),
  ];

  static Color avatarColor(String id) => avatarColors[id.hashCode.abs() % avatarColors.length];

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 1,
      iconTheme: IconThemeData(color: Color(0xFF374151)),
      titleTextStyle: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: primary, foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: const Color(0xFFF9FAFB),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primary.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: 1),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), elevation: 0, scrolledUnderElevation: 1),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B), elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF334155))),
    ),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xFF1E293B)),
  );
}
