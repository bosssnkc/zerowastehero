import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/session.dart';

class profilePage extends StatelessWidget {
  const profilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
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
            const Card(
              child: ListTile(
                title: Text(
                  '{user_fname} {user_lname}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('{user email}'),
                contentPadding: EdgeInsets.all(16),
                leading: Icon(Icons.person),
              ),
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
                onTap: () {},
                title: Text('แก้ไขข้อมูลส่วนตัว'),
                leading: Icon(Icons.edit),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {},
                title: Text('แก้ไขรหัสผ่าน'),
                leading: Icon(Icons.lock_rounded),
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
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () => _logout(context),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              tooltip: 'ลงชื่อออก',
              style: IconButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
