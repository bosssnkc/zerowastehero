import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/database/manage_user.dart';
import 'package:zerowastehero/session.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('username'); // Remove stored username
    prefs.remove('user_id');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  void clearFields() {
    _currentPasswordController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Unknown User';
    String? token = prefs.getString('jwt_token');
    // print(token);

    final response = await http.get(
      Uri.parse('$getuserinfo$username'),
      headers: {'Authorization': '$token'},
    );
    if (token != null) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (isExpired) {
        // Token is expired, redirect to login page
        prefs.setBool('isLoggedIn', false);
        prefs.remove('username');
        prefs.remove('user_id');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Session หมดอายุ'),
              content: const Text('Session กรุณาทำการล็อกอินใหม่'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ตกลง'),
                ),
              ],
            ),
          );
        }
      } else {
        // Token is still valid, proceed as normal
      }
    } else {
      // No token found, redirect to login page
      prefs.setBool('isLoggedIn', false);
      prefs.remove('username');
      prefs.remove('user_id');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('พบการเข้าถึงที่ไม่ถูกต้อง'),
            content: const Text('การเข้าถึงไม่ถูกต้อง กรุณาทำการล็อกอินใหม่'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> userInfo = jsonDecode(response.body);
      return userInfo;
    } else {
      return {
        'firstname': 'Unknown firstname',
        'lastname': 'Unknown lastname',
        'email': 'unknown@example.com'
      };
    }
  }

  Future<void> _editPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านใหม่ไม่ตรงกัน')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    if (username.isNotEmpty) {
      String currentPassword = _currentPasswordController.text;
      String newPassword = _passwordController.text;

      final response = await http.post(
        Uri.parse(updatePassword),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        clearFields(); //เรียกใช้ฟังก์ชันเคลียข้อมูลเมื่อทำการเปลี่ยนรหัสผ่านเรียบร้อย
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสผ่านปัจจุบันไม่ถูกต้อง')),
        );
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'บัญชีผู้ใช้งาน',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // FutureBuilder<Map<String, dynamic>>(
            //   future: _getUserInfo(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Card(
            //         child: ListTile(
            //           title: Text(
            //             'Loading...',
            //             style: TextStyle(fontWeight: FontWeight.bold),
            //           ),
            //           contentPadding: EdgeInsets.all(16),
            //           leading: Icon(Icons.person),
            //         ),
            //       );
            //     } else if (snapshot.hasError) {
            //       return const Card(
            //         child: ListTile(
            //           title: Text(
            //             'Error loading user info',
            //             style: TextStyle(fontWeight: FontWeight.bold),
            //           ),
            //           contentPadding: EdgeInsets.all(16),
            //           leading: Icon(Icons.error),
            //         ),
            //       );
            //     } else {
            //       final userInfo = snapshot.data!;
            //       return Card(
            //         child: ListTile(
            //           title: Text(
            //             '${userInfo['fullname']!} ${userInfo['lastname']!}',
            //             style: const TextStyle(fontWeight: FontWeight.bold),
            //           ),
            //           subtitle: Text(userInfo['email']!),
            //           contentPadding: const EdgeInsets.all(16),
            //           leading: const Icon(
            //             Icons.person,
            //             size: 50,
            //           ),
            //         ),
            //       );
            //     }
            //   },
            // ),
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: ListTile(
                      title: Text(
                        'Loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(Icons.person),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Card(
                    child: ListTile(
                      title: Text(
                        'Error loading user info',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(Icons.error),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final userInfo = snapshot.data!;
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${userInfo['firstname']} ${userInfo['lastname']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(userInfo['email']!),
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                  );
                } else {
                  return const Card(
                    child: ListTile(
                      title: Text(
                        'User not found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(Icons.error),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'ตั้งค่าผู้ใช้งาน',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ManageUsersPage(),
                  ));
                },
                title: const Text('แก้ไขข้อมูลส่วนตัว'),
                leading: const Icon(Icons.edit),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('แก้ไขรหัสผ่าน'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('กรุณากรอก Password ปัจจุบัน'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'password ปัจจุบัน',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('กรุณากรอก Password ใหม่'),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'password ใหม่',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: true,
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ยืนยัน password ใหม่',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          clearFields();
                          Navigator.of(context).pop();
                        },
                        child: const Text('ยกเลิก'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green),
                        onPressed: () async {
                          await _editPassword();
                        },
                        child: const Text('บันทึก'),
                      ),
                    ],
                  ),
                ),
                title: const Text('แก้ไขรหัสผ่าน'),
                leading: const Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.logout),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _logout(context),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
