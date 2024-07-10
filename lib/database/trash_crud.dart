import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zerowastehero/database/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class manageTrash extends StatefulWidget {
  const manageTrash({super.key});

  @override
  State<manageTrash> createState() => _manageTrashState();
}

class _manageTrashState extends State<manageTrash> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _trash = [];
  final ImagePicker _picker = ImagePicker();
  Uint8List? _image;

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

  Future<void> _pickImage() async {
    final permissionStatus = await _requestPermission();
    if (permissionStatus) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = bytes;
        });
      }
    }
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Handle permission denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission needed'),
          content: Text('This app needs photo access to pick images'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    return false;
  }

  void _showTrash({Map<String, dynamic>? trash}) {
    final _trashnameController =
        TextEditingController(text: trash?['trash_name']);
    final _trashtypeController =
        TextEditingController(text: trash?['trash_type']);
    final _trashdesController =
        TextEditingController(text: trash?['trash_des']);

    if (trash != null && trash['trash_pic'] != null) {
      _image = Uint8List.fromList(trash['trash_pic']);
    }

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
                decoration: InputDecoration(labelText: 'Trash Name'),
              ),
              TextField(
                controller: _trashtypeController,
                decoration: InputDecoration(labelText: 'Trash Type'),
              ),
              TextField(
                controller: _trashdesController,
                decoration: InputDecoration(labelText: 'Trash Description'),
              ),
              SizedBox(height: 10),
              _image != null
                  ? Image.memory(
                      _image!,
                      height: 100,
                      width: 100,
                    )
                  : Text('No Image Selected'),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
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
                'trash_pic': _image ?? trash?['trash_pic'],
              };
              if (trash == null) {
                await _dbHelper.insertTrash1(newTrash);
              } else {
                newTrash['trash_id'] = trash['trash_id'];
                await _dbHelper.updateTrash(newTrash);
              }
              Navigator.of(context).pop();
              _loadTrashs();
            },
            child: Text(trash == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
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
              leading: trash['trash_pic'] != null
                  ? Image.memory(Uint8List.fromList(trash['trash_pic']))
                  : Icon(Icons.error),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showTrash(trash: trash),
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _dbHelper.deleteTrash(trash['trash_id']);
                      _loadTrashs();
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTrash(),
        child: Icon(Icons.add),
      ),
    );
  }
}
