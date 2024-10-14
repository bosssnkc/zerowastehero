import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
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

  bool _isValidUsername(String username) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return validCharacters.hasMatch(username);
  }

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

      String password = _passwordController.text;
      String email = _emailController.text;
      String fullname = _fullnameController.text;
      String lastname = _lastnameController.text;
      String gender = _gender!;
      String birthdate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String dateReg = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // สร้าง JSON data
      Map<String, dynamic> data = {
        'username': username,
        'password': password,
        'date_reg': dateReg,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        backgroundColor: Colors.green[300],
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/zwh_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              autovalidateMode: AutovalidateMode.always,
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
                        } else if (!value.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
                          return 'ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษหรือตัวเลขเท่านั้น';
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
                        } else if (value.length < 8) {
                          return 'รหัสผ่านควรมีความยาวอย่างน้อย 8 ตัว';
                        } else if (!value.contains(
                          RegExp(r'^[a-zA-Z0-9!@#.%^&*]+$'),
                        )) {
                          return 'รหัสผ่านควรเป็นภาษาอังกฤษ ตัวอักษรพิเศษ หรือตัวเลขเท่านั้น';
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
                        } else if (!value
                            .contains(RegExp(r'^[a-zA-Z0-9!@#.%^&*]+$'))) {
                          return 'รหัสผ่านควรเป็นภาษาอังกฤษ ตัวอักษรพิเศษ หรือตัวเลขเท่านั้น';
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
                        } else if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'รูปแบบ email ไม่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fullnameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อ',
                        hintText: 'ชื่อ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อ';
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
      ),
    );
  }
}
