import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'database_helper.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
    });
  }

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  void _showForm({Map<String, dynamic>? user}) {
    final _usernameController = TextEditingController(text: user?['username']);
    final _passwordController = TextEditingController(text: user?['password']);
    final _emailController = TextEditingController(text: user?['email']);
    final _fullnameController = TextEditingController(text: user?['fullname']);
    final _lastnameController = TextEditingController(text: user?['lastname']);
    final _gender = TextEditingController(text: user?['gender']);
    final _birthdate = TextEditingController(text: user?['birthdate']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _fullnameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: _lastnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _gender,
                decoration:
                    InputDecoration(labelText: 'Gender', hintText: 'ชาย/หญิง'),
              ),
              TextField(
                controller: _birthdate,
                decoration: InputDecoration(
                    labelText: 'Birthdate', hintText: 'YYYY-MM-dd'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUser = {
                'username': _usernameController.text,
                'password': _hashPassword(_passwordController.text),
                'date_reg': DateTime.now().toIso8601String(),
                'email': _emailController.text,
                'fullname': _fullnameController.text,
                'lastname': _lastnameController.text,
                'gender': _gender.text,
                'birthdate': _birthdate.text
              };
              if (user == null) {
                await _dbHelper.insertUser1(newUser);
              } else {
                newUser['user_id'] = user['user_id'].toString();
                await _dbHelper.updateUser(newUser);
              }
              Navigator.of(context).pop();
              _loadUsers();
            },
            child: Text(user == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user['username']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(user: user),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _dbHelper.deleteUser(user['user_id']);
                    _loadUsers();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
