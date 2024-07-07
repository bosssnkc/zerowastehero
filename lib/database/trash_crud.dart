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
              title: Text(trash == null ? 'Add Trash' : 'Edit Trash'),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newTrash = {
                      'trash_name': _trashnameController.text,
                      'trash_type': _trashtypeController.text,
                      'trash_des': _trashdesController.text,
                    };
                    if (trash == null) {
                      await _dbHelper.insertTrash1(newTrash);
                    } else {
                      newTrash['trash_id'] = trash['trash_id'].toString();
                      await _dbHelper.updateTrash(newTrash);
                    }
                    Navigator.of(context).pop();
                    _loadTrashs();
                  },
                  child: Text(trash == null ? 'Add' : 'Save'),
                ),
              ],
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
