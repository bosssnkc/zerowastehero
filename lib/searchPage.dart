import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class searchPage extends StatefulWidget {
  const searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  List<dynamic> _trash = [];

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashnamesearch = prefs.getString('trashname') ?? '';
    if (trashnamesearch == '') {
      //
      final response = await http.get(
        Uri.parse('https://zerowasteheroapp.com/search/alltrashs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> trashs = jsonDecode(response.body);
        setState(() {
          _trash = trashs;
        });
      }
    } else {
      // final search = await _dbHelper.getGTrashItem(trashnamesearch);
      final response = await http.get(
        Uri.parse(
            'https://zerowasteheroapp.com/search/trashs?name=$trashnamesearch'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> search = jsonDecode(response.body);
        setState(() {
          _trash = search;
        });
      }

      prefs.remove('trashname');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text(
          'ค้นหารายการขยะ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _trash.length,
          itemBuilder: (context, index) {
            final trash = _trash[index];
            return Card(
              child: ListTile(
                title: Text(trash['trash_name']),
                subtitle: Text(trash['trash_type']),
                leading: trash['trash_pic'] != null
                    ? Icon(Icons.error_outline)
                    : Icon(Icons.error),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => (trash: trash),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        // await _dbHelper.deleteTrash(trash['trash_id']);
                        _loadTrash();
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
