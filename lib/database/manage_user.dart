import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Unknown User';
    String token = prefs.getString('jwt_token') ?? '';

    final response = await http.get(
      Uri.parse('$getuserinfo$username'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userInfo = jsonDecode(response.body);
      setState(() {
        _firstnameController.text = userInfo['firstname'];
        _lastnameController.text = userInfo['lastname'];
        _emailController.text = userInfo['email'];
      });
    } else {
      // Handle the error scenario
      // print('Failed to fetch user info');
    }
  }

  Future<void> _updateUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Unknown User';
    String token = prefs.getString('jwt_token') ?? '';

    Map<String, dynamic> updatedInfo = {
      'firstname': _firstnameController.text,
      'lastname': _lastnameController.text,
      'email': _emailController.text,
    };

    final response = await http.put(
      Uri.parse('$update_userinfo$username'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
      body: jsonEncode(updatedInfo),
    );

    if (response.statusCode == 200) {
      // เมื่ออัพเดทข้อมูลสำเร็จ
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัพเดทข้อมูลผู้ใช้สำเร็จ')),
      );
    } else {
      // เมื่อไม่สามารถอัพเดทข้อมูลได้
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถอัพเดทข้อมูลได้')),
      );
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        backgroundColor: Colors.green[300],
        title: const Text(
          'จัดการบัญชีผู้ใช้งาน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/zwh_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('แก้ไขข้อมูลผู้ใช้'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstnameController,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรอกชื่อ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastnameController,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'นามสกุล',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรอกนามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรอกอีเมล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserInfo,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                child: const Text('อัพเดทข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
