import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerowastehero/API/api.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  String? _gender;
  DateTime? _selectedDate;

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  bool _isValidUsername(String username) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return validCharacters.hasMatch(username);
  }

  // Future<void> _register() async {
  //   if (_formKey.currentState!.validate()) {
  //     String username = _usernameController.text;
  //     String password = _hashPassword(_passwordController.text);
  //     String email = _emailController.text;
  //     String fullname = _fullnameController.text;
  //     String lastname = _lastnameController.text;
  //     String gender = _gender!;
  //     String birthdate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

  //     if (!await _isUsernameTaken(username)) {
  //       if (_isValidUsername(username)) {
  //         final dbHelper = DatabaseHelper();
  //         await dbHelper.insertUser(
  //             username,
  //             password,
  //             DateTime.now().toIso8601String(),
  //             email,
  //             fullname,
  //             lastname,
  //             gender,
  //             birthdate);

  //         Navigator.of(context).pop();
  //       } else {
  //         // แสดง Error เมื่อผู้ใช้งานใส่รูปแบบตัวอักษรไม่ถูกต้อง
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: Text('Invalid Username'),
  //             content: Text(
  //                 'ชื่อผู้ใช้สามารถใช้ได้แค่ตัวอักษร ภาษาอังกฤษ a-Z, 0-9 เท่านั้น'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: Text('OK'),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //     } else {
  //       // แสดง Error เมื่อมี username นี้อยู่ในระบบอยู่แล้ว
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text('Username Taken'),
  //           content: Text(
  //               'This username is already taken. Please choose another one.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: Text('OK'),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;

      // ตรวจสอบความถูกต้องของ username
      if (!_isValidUsername(username)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Username'),
            content: const Text(
                'Username ต้องเป็นตัวอักษรภาษาอังกฤษหรือตัวเลขเท่านั้น'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      String password = _hashPassword(_passwordController.text);
      String email = _emailController.text;
      String fullname = _fullnameController.text;
      String lastname = _lastnameController.text;
      String gender = _gender!;
      String birthdate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // สร้าง JSON data
      Map<String, dynamic> data = {
        'username': username,
        'password': password,
        'date_reg': DateTime.now().toIso8601String(),
        'email': email,
        'firstname': fullname,
        'lastname': lastname,
        'gender': gender,
        'birthdate': birthdate
      };

      // ส่งข้อมูลไปยัง Rest API
      final response = await http.post(
        Uri.parse(register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // การลงทะเบียนสำเร็จ
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Successful'),
            content: const Text('การลงทะเบียนเสร็จสมบูรณ์'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'))
            ],
          ),
        );
      } else {
        // แสดง Error message จาก API
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('การลงทะเบียนล้มเหลว: ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _fullnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ลงทะเบียนบัญชีใหม่',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้',
                      hintText: 'username',
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'ยืนยันรหัสผ่าน',
                      hintText: '**********',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่าน';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล์',
                      hintText: 'example@gmail.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล์';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _fullnameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อจริง',
                      hintText: 'ชื่อจริง',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อจริง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'นามสกุล',
                      hintText: 'นามสกุล',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกนามสกุล';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'เพศ',
                      border: OutlineInputBorder(),
                    ),
                    items: ['ชาย', 'หญิง']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'กรุณาเลือกเพศ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'วันเกิด',
                            hintText: 'วัน/เดือน/ปี พ.ศ.',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาเลือกวันเกิด';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('ลงทะเบียน'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('ยกเลิก'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
