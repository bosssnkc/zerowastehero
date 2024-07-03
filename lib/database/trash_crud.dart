import 'package:flutter/material.dart';
import 'package:zerowastehero/database/database_helper.dart';

class manageTrash extends StatefulWidget {
  const manageTrash({super.key});

  @override
  State<manageTrash> createState() => _manageTrashState();
}

class _manageTrashState extends State<manageTrash> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _trash = [];

  @override
  void initState() {
    super.initState();
    _loadTrashs();
  }

  Future<void> _loadTrashs() async {
    final trashs = await _dbHelper.getTrash();
    setState(() {
      _trash = trashs;
    });
  }

  void _showTrash({Map<String, dynamic>? trash}) {
    final _trashnameController =
        TextEditingController(text: trash?['trash_name']);
    final _trashtypeController =
        TextEditingController(text: trash?['trash_type']);
    final _trashdesController =
        TextEditingController(text: trash?['trash_des']);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('test'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _trashnameController,
                      decoration: InputDecoration(labelText: 'trashname'),
                    ),
                    TextField(
                      controller: _trashtypeController,
                      decoration: InputDecoration(labelText: 'trashtype'),
                    ),
                    TextField(
                      controller: _trashdesController,
                      decoration: InputDecoration(labelText: 'trashdes'),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Trash Item')),
      body: ListView.builder(
          itemCount: _trash.length,
          itemBuilder: (context, index) {
            final trash = _trash[index];
            return Card(
              child: ListTile(
                title: Text(trash['trash_name']),
                subtitle: Text(trash['trash_type']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showTrash(trash: trash),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () async {
                          await _dbHelper.deleteTrash(trash['trash_id']);
                          _loadTrashs();
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTrash(),
        child: Icon(Icons.add),
      ),
    );
  }
}
