import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/main_menu.dart';
import 'package:zerowastehero/register.dart';

import 'package:http/http.dart' as http;

//หน้าล็อกอินและจัดเก็บข้อมูลการล็อกอิน

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
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
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotUsernameController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  Future<void> createGuestToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('guestToken');
    String? guestToken = prefs.getString('guestToken');

    if (guestToken == null) {
      guestToken = Uuid().v4();
      await prefs.setString('guestToken', guestToken);
      await prefs.setBool('isLoggedIn', true);
      print(guestToken);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  Future<void> _forgotPassword() async {
    String forgotUsername = _forgotUsernameController.text;
    String forgotEmail = _forgotEmailController.text;

    try {
      final response = await http.post(
        Uri.parse(forgotPassword),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': forgotUsername,
          'email': forgotEmail,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('รหัสผ่านถูกรีเซ็ต'),
                  content: const Text(
                      'กรุณาตรวจสอบ E-mail เพื่อรับรหัสผ่านที่ถูกรีเซ็ต หากไม่พบ email ให้ตรวจสอบใน เมล์ขยะ/Junk Mail'),
                  actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('ตกลง'))
                  ],
                ));
      } else if (response.statusCode == 301) {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('ข้อผิดพลาด ${response.statusCode}'),
                  content: const Text('301'),
                  actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('ตกลง'))
                  ],
                ));
      } else {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('ข้อผิดพลาด ${response.statusCode}'),
                  content: const Text(
                      'ไม่สามารถรีเซ็ตรหัสผ่านได้ username หรือ email ไม่ถูกต้องกรุณาลองใหม่'),
                  actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('ตกลง'))
                  ],
                ));
      }
    } catch (e) {
      print('Error $e');
    }
  }

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
        await prefs.setInt('role', responseData['role']);
        print('Your Role is ${prefs.getInt('role')}');
        await prefs.setString('user_id', responseData['user_id'].toString());
        // await prefs.setString('jwt_token', responseData['token']);
        await prefs.setString('jwt_token', token!);
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ข้อผิดพลาด'),
              content: const Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
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
      backgroundColor: Colors.green[50],
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
          'Yaek and Ting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                const Image(image: AssetImage('assets/image/Logo.png'),height: 120, width: 120,),
                const SizedBox(height: 10,),
                const Text('แยกแล้วทิ้งแอปพลิเคชัน',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                const Text('Yaek and Ting Application',style: TextStyle(fontSize: 16,),),
                const SizedBox(height: 40,),
                const Text(
                  'ลงชื่อเข้าใช้งาน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    hintText: 'username',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
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
                    floatingLabelBehavior: FloatingLabelBehavior.always,
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
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('ลืมรหัสผ่าน'),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: Form(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _forgotUsernameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Username',
                                          hintText:
                                              'username ที่เคยลงทะเบียนไว้'),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    TextFormField(
                                      controller: _forgotEmailController,
                                      decoration: const InputDecoration(
                                          labelText: 'Email',
                                          hintText: 'email@example.com'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                _forgotPassword();
                              },
                              child: const Text(
                                'ตกลง',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  _forgotEmailController.clear();
                                  _forgotUsernameController.clear();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('ยกเลิก'))
                          ],
                        ),
                      );
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
                        builder: (context) => const RegisterPage(),
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
                    createGuestToken();
                    // ฟังก์ชันการสร้างบัญชีชั่วคราว
                  },
                  child: const Text(
                    'เข้าใช้งานโดยไม่ใช้บัญชี',
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
