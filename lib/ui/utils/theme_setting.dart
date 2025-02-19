import 'package:flutter/material.dart';

class ThemeSetting {
  static const Color principalColor = Color(0xff4D96FF);
  static const Color redColor = Color(0xffFF6B6B);
  static const Color greenColor = Color(0xff6BCB77);
  static const Color borderColor = Color(0xFFC2BFBF);

static const TextStyle titleStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
  static ThemeData themeData = ThemeData(
      useMaterial3: true,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(principalColor),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      fontFamily: "Poppins",
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStateProperty.all(principalColor),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          fixedSize: const WidgetStatePropertyAll(Size(double.maxFinite, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: principalColor),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: borderColor),
        ),
      ));
}