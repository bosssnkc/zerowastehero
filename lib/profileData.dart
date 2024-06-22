import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/database/database_helper.dart';
import 'package:zerowastehero/database/db_crud.dart';
import 'package:zerowastehero/session.dart';

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Unknown User';
    final dbHelper = DatabaseHelper();
    Map<String, dynamic>? userInfo = await dbHelper.getUser(username);
    if (userInfo == null) {
      return {'fullname': 'Unknown User', 'email': 'unknown@example.com'};
    }
    return userInfo;
  }

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
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
      final dbHelper = DatabaseHelper();
      String currentPasswordHash =
          _hashPassword(_currentPasswordController.text);
      Map<String, dynamic>? userInfo = await dbHelper.getUser(username);

      if (userInfo != null && userInfo['password'] == currentPasswordHash) {
        String newPasswordHash = _hashPassword(_passwordController.text);
        await dbHelper.updatePassword(username, newPasswordHash);
        Navigator.of(context).pop();
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
                } else {
                  final userInfo = snapshot.data!;
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${userInfo['fullname']!} ${userInfo['lastname']!}',
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
                    builder: (context) => ManageUsersPage(),
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      ElevatedButton(
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
              alignment: Alignment.centerRight,
              children: <Widget>[
                const Icon(Icons.logout),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _logout(context),
                  child: const Text('Logout'),
                ),
              ],
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () => _logout(context),
            ),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'ลงชื่อออก',
              style: IconButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
