import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistTheme {
  // Główne kolory
  static const Color black = Color(0xFF050505);
  static const Color neonRed = Color(0xFFFF003C);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1A1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: pureWhite,
      primaryColor: neonRed,
      colorScheme: const ColorScheme.light(
        primary: neonRed,
        secondary: black,
        surface: pureWhite,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.anton(fontSize: 48, color: black, height: 1.1, letterSpacing: 2.0),
        displayMedium: GoogleFonts.anton(fontSize: 32, color: black, height: 1.1, letterSpacing: 1.5),
        headlineLarge: GoogleFonts.anton(fontSize: 24, color: neonRed, letterSpacing: 1.0),
        titleLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w900, color: black),
        bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: black),
        bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[800]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: pureWhite,
          elevation: 0,
          shape: const BeveledRectangleBorder(side: BorderSide(color: neonRed, width: 2)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.anton(fontSize: 20, letterSpacing: 2.0),
        ),
      ),
      cardTheme: const CardTheme(
        color: pureWhite,
        elevation: 0,
        shape: BeveledRectangleBorder(side: BorderSide(color: black, width: 3)),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: black, width: 2)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: neonRed, width: 3)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.anton(fontSize: 28, color: black, letterSpacing: 3.0),
        iconTheme: const IconThemeData(color: black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: neonRed,
      colorScheme: const ColorScheme.dark(
        primary: neonRed,
        secondary: pureWhite,
        surface: darkGray,

      ),
      
      // Gruba, brutalistyczna czcionka nagłówków (np. Anton, Bebas Neue, lub Roboto Black)
      // Użyjemy Anton dla maksymalnego uderzenia, a dla tekstu zwykłego Roboto
      textTheme: TextTheme(
        displayLarge: GoogleFonts.anton(
          fontSize: 48,
          color: pureWhite,
          height: 1.1,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.anton(
          fontSize: 32,
          color: pureWhite,
          height: 1.1,
          letterSpacing: 1.5,
        ),
        headlineLarge: GoogleFonts.anton(
          fontSize: 24,
          color: neonRed,
          letterSpacing: 1.0,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: pureWhite,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: pureWhite,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.grey[400],
        ),
      ),

      // Stylizacja przycisków
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonRed,
          foregroundColor: pureWhite,
          elevation: 0,
          shape: const BeveledRectangleBorder(), // Surowe, ostre krawędzie
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.anton(
            fontSize: 20,
            letterSpacing: 2.0,
          ),
        ),
      ),

      // Stylizacja kart (surowe, bez zaokrągleń)
      cardTheme: const CardTheme(
        color: darkGray,
        elevation: 0,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: neonRed, width: 2),
        ),
        margin: EdgeInsets.all(8),
      ),

      // Pola tekstowe
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: neonRed, width: 3),
        ),
        labelStyle: GoogleFonts.roboto(
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.anton(
          fontSize: 28,
          color: neonRed,
          letterSpacing: 3.0,
        ),
        iconTheme: const IconThemeData(color: pureWhite),
      ),
    );
  }
}
