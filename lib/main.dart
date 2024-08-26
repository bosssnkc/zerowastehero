import 'package:flutter/material.dart';
import 'package:zerowastehero/session.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Zero Waste Hero',
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.grey),
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
            labelStyle: GoogleFonts.prompt(),
            unselectedLabelStyle: GoogleFonts.kanit(),
          ),
          primarySwatch: Colors.green,
          textTheme: GoogleFonts.kanitTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        // darkTheme: ThemeData.dark(),
        home: SplashScreen());
  }
}
