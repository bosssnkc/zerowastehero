import 'package:flutter/material.dart';
import 'package:zerowastehero/session.dart';
import 'package:zerowastehero/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey key = GlobalKey();
  String selectedFont = 'Kanit';

  @override
  void initState() {
    super.initState();
    _loadFontPref();
  }

  Future<void> _loadFontPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFont = prefs.getString('selectedFont') ?? 'Kanit';
      key = GlobalKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: key,
      title: 'Yaek and Ting',
      theme: ThemeClass.lightTheme(selectedFont),
      home: const SplashScreen(),
      // เข้าสู่หน้า SplashScreen เพื่อทำการตรวจสอบการล็อกอิน
      // หากมีข้อมูลว่ากำลังล็อกอินอยู่จะเข้าสู่หน้าหลักทันที
    );
  }
}
