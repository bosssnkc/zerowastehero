import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/database/manage_user.dart';
import 'package:zerowastehero/main_menu.dart';
import 'package:zerowastehero/register.dart';

import 'package:http/http.dart' as http;

//หน้าล็อกอินและจัดเก็บข้อมูลการล็อกอิน

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      ); // เมื่อล็อกอินสมบูรณ์แล้วจะทำการเปลี่ยนหน้าไปยังหน้าหลัก
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      ); // หากล็อกอินไม่สมบูรณ์จะกลับไปยังหน้าล็อกอินหน้าเดิม
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green[100],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.green,
              ),
              Text('Loading'),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      final response = await http.post(
        Uri.parse(login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = response.headers['authorization'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('user_id', responseData['user_id'].toString());
        // await prefs.setString('jwt_token', responseData['token']);
        await prefs.setString('jwt_token', token!);
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ข้อผิดพลาด'),
              content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
              actions: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zero Waste Hero',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ลงชื่อเข้าใช้งาน',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้/อีเมล์',
                    hintText: 'example@gmail.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้หรืออีเมล์';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน',
                    hintText: '**********',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // ฟังก์ชันกู้คืนรหัสผ่าน
                    },
                    child: const Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _usernameController.clear();
                        _passwordController.clear();
                        // ฟังก์ชันยกเลิกหรือล้างฟอร์มด้านบน
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      child: const Text('ยกเลิก',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('ยังไม่มีบัญชีผู้ใช้?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'ลงทะเบียนตอนนี้',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const Text('หรือ'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageUsersPage(),
                    ));
                    // ฟังก์ชันการสร้างบัญชีชั่วคราว
                  },
                  child: const Text(
                    'เข้าใช้งานด้วยบัญชีชั่วคราว',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
