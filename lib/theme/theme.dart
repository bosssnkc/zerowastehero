import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeClass {
  static ThemeData lightTheme(String fontFamily) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.green.shade50,
      cardTheme: const CardTheme(color: Colors.white, shadowColor: Colors.grey),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        hintFadeDuration: Duration(seconds: 1),
        border: OutlineInputBorder(),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorColor: const Color(0xff1d976c),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        labelStyle: GoogleFonts.getFont(fontFamily), // ฟอนต์ที่เลือก
        unselectedLabelStyle: GoogleFonts.getFont(fontFamily), // ฟอนต์ที่เลือก
      ),
      textTheme: GoogleFonts.getTextTheme(fontFamily), // ฟอนต์ที่เลือก
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green, foregroundColor: Colors.white),
    );
  }

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.purple),
        actionsIconTheme: IconThemeData(color: Colors.purple)),
    tabBarTheme: TabBarTheme(
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      indicatorColor: const Color(0xff1d976c),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      labelStyle: GoogleFonts.prompt(),
      unselectedLabelStyle: GoogleFonts.kanit(),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black, foregroundColor: Colors.green),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.black,
      labelStyle: TextStyle(color: Colors.deepPurple),
      hintFadeDuration: Duration(seconds: 1),
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    ),
    cardTheme: const CardTheme(shadowColor: Colors.grey),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.purple,
    ),
    scaffoldBackgroundColor: Color.fromARGB(255, 22, 22, 22),
    primaryColorDark: Colors.deepOrange,
    textTheme: GoogleFonts.kanitTextTheme(const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.deepPurple),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.deepPurple),
    ),
  );
}

ThemeClass _themeClass = ThemeClass();
