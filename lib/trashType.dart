import 'package:flutter/material.dart';

class typeOfTrash extends StatelessWidget {
  const typeOfTrash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        elevation: 0,
        title: const Text(
          'ขยะ 4 ประเภท',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('data'),
                TextField(
                  decoration: InputDecoration(
                      labelText: "test",
                      hintText: "ค้นหาอะไรสักอย่างดิวะ",
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.search),
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
