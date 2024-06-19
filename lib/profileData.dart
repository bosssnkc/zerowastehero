import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/database/database_helper.dart';
import 'package:zerowastehero/database/db_crud.dart';
import 'package:zerowastehero/session.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    print(prefs.getString('username'));
    final dbHelper = DatabaseHelper();
    Map<String, dynamic>? userInfo = await dbHelper.getUser(username);
    if (userInfo == null) {
      return {'fullname': 'Unknown User', 'email': 'unknown@example.com'};
    }
    return userInfo;
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
            const SizedBox(
              height: 8,
            ),
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
            const SizedBox(
              height: 16,
            ),
            const Text(
              'ตั้งค่าผู้ใช้งาน',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
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
                    title: Text('แก้ไขรหัสผ่าน'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('กรุณากรอก Password ปัจจุบัน'),
                        SizedBox(
                          height: 3,
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'password ปัจจุบัน'),
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'password ปัจจุบัน'),
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'password ปัจจุบัน'),
                        ),
                      ],
                    ),
                  ),
                ),
                title: const Text('แก้ไขรหัสผ่าน'),
                leading: const Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                const Icon(Icons.logout),
                TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _logout(context),
                    child: const Text('Logout'))
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
