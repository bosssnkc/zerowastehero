import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/database/db_crud.dart';
import 'package:zerowastehero/mainMenu.dart';
import 'package:zerowastehero/register.dart';

import 'database/database_helper.dart';

//หน้าล็อกอินและจัดเก็บข้อมูลการล็อกอิน

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainPage()),
      ); // เมื่อล็อกอินสมบูรณ์แล้วจะทำการเปลี่ยนหน้าไปยังหน้าหลัก
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      ); // หากล็อกอินไม่สมบูรณ์จะกลับไปยังหน้าล็อกอินหน้าเดิม
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _hashPassword(_passwordController.text);

      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUser(username);

      if (user == null) {
        // แสดง AlertDialog เมื่อไม่พบชื่อผู้ใช้
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ข้อผิดพลาด'),
              content: Text('ไม่พบชื่อผู้ใช้'),
              actions: [
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (user['password'] != password) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ข้อผิดพลาด'),
              content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
              actions: [
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username',
            username); //ส่งค่าชื่อไอดีเพื่อไปแสดงผลข้อมูลในหน้าบัญชีผู้ใช้
        prefs.setBool('isLoggedIn',
            true); //เปลี่ยนค่าล็อกอินให้เป็น True เมื่อทำงานสมบูรณ์
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage()),
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
        backgroundColor: Colors.green[300],
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
                      ),
                      child: const Text('เข้าสู่ระบบ'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ฟังก์ชันยกเลิกหรือล้างฟอร์มด้านบน
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('ยกเลิก'),
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
