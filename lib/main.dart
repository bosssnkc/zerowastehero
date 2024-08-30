import 'package:flutter/material.dart';
import 'package:zerowastehero/session.dart';
import 'package:zerowastehero/theme/theme.dart';

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
        theme: ThemeClass.lightTheme,
        home: SplashScreen());
  }
}
