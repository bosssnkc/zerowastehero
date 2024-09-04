import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:zerowastehero/Routes/routes.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _trash = [];
  bool _isLoading = true;
  int _itemsToShow = 10;
  bool _isSearchClicked = false;
  final _searchBoxController = TextEditingController();
  String? _userData = '';
  final _trashNameController = TextEditingController();
  final _trashDesController = TextEditingController();
  String? trashtypePicker;
  Uint8List? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTrash();
    _loadUserData();
    setState(() {});
  }

  Future<void> getTrashUpdateInfo(dynamic trashlist) async {
    print(trashlist);
    setState(() {
      _trashNameController.text = trashlist['trash_name'];
      _trashDesController.text = trashlist['trash_des'];
      trashtypePicker = trashlist['trash_type'];
      _image = trashlist['trash_pic'] != null
          ? base64Decode(trashlist['trash_pic'])
          : null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Collect updated data
                final updatedTrash = {
                  'trash_name': _trashNameController.text,
                  'trash_des': _trashDesController.text,
                  'trash_type': trashtypePicker,
                  // If a new image was selected, add it to the updated data
                  'trash_pic': _image != null
                      ? base64Encode(_image!)
                      : trashlist['trash_pic'] ?? '',
                  'trash_id': trashlist['trash_id']
                };

                // Send the update request to the server
                final response = await http.put(
                  Uri.parse(updatetrash),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(updatedTrash),
                );

                if (response.statusCode == 200) {
                  print('Trash updated successfully'); //Debug if failed
                  trashlist['trash_pic'] = _image != null
                      ? base64Encode(_image!)
                      : trashlist['trash_pic'];
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('อัพเดทสำเร็จ'),
                      content: const Text('อัพเดทข้อมูลสำเร็จ'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  print('Failed to update trash'); //Debug if failed
                  String message =
                      'Error ${response.statusCode}: ${response.reasonPhrase}';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                _loadTrash();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text(
                'บันทึก',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                _loadTrash();
              },
              child: const Text('ยกเลิก'),
            ),
          ],
          insetPadding: const EdgeInsets.all(16),
          title: const Text('แก้ไขรายการขยะ'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _trashNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรอกชื่อขยะ';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'ชื่อขยะ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: trashtypePicker,
                    items: [
                      'ขยะทั่วไป',
                      'ขยะอินทรีย์',
                      'ขยะรีไซเคิล',
                      'ขยะอันตราย'
                    ]
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        trashtypePicker = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 7,
                    controller: _trashDesController,
                    decoration: const InputDecoration(
                      labelText: 'รายละเอียดขยะ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('รูปภาพ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      ElevatedButton(
                        onPressed: () async {
                          await _pickImage();
                          setState(() {
                            if (_image != null) {
                              trashlist['trash_pic'] = base64Encode(_image!);
                            }
                          });
                        },
                        child: const Text('อัพโหลดหรือเปลี่ยนรูปภาพ'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  trashlist['trash_pic'] != null
                      ? Stack(
                          children: [
                            Positioned(
                              child: Image.memory(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                base64Decode(trashlist['trash_pic']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () async {
                                  setState(() {
                                    _image = null;

                                    trashlist['trash_pic'] = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        )
                      : const Icon(Icons.image_not_supported),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteTrashWindow(dynamic listtrash) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('ยืนยันการลบรายการขยะ'),
              insetPadding: const EdgeInsets.all(16),
              content: Text(
                  'ต้องการลบรายการขยะ ${listtrash['trash_name']} ใช่หรือไม่'),
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      try {
                        final response = await http.put(
                          Uri.parse(deletetrash),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(
                            {'trash_id': listtrash['trash_id']},
                          ),
                        );
                        if (response.statusCode == 200) {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('ลบข้อมูลสำเร็จ'),
                              content: const Text('ลบข้อมูลสำเร็จ'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ตกลง'))
                              ],
                            ),
                          );
                        } else if (response.statusCode == 404) {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('ลบข้อมูลไม่สำเร็จ'),
                              content: const Text('Error 404 ไม่พบรายการขยะ'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ตกลง'))
                              ],
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('ลบข้อมูลไม่สำเร็จ'),
                              content: const Text('ลบข้อมูลรายการขยะไม่สำเร็จ'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ตกลง'))
                              ],
                            ),
                          );
                        }
                      } catch (error) {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('ไม่สามารถลบได้'),
                                  content: const Text(
                                      'ไม่สามารถลบข้อมูลได้ Database Error'),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('ตกลง'))
                                  ],
                                ));
                      }
                      _loadTrash();
                    },
                    child: const Text('ยืนยันการลบ')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadTrash();
                    },
                    child: const Text('ยกเลิก'))
              ],
            ));
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
          title: const Text('Permission needed'),
          content: const Text('This app needs photo access to pick images'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    return false;
  }

  Future<void> _onChangedSearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashnamesearch = _searchBoxController.text;
    await prefs.setString('trashname', trashnamesearch);
  }

  Future<void> _selectTypeTrash(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$searchtrashs?trash_type=$type'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _trash = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _loadTrash();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userData = prefs.getString('user_id');
  }

  Future<void> _loadTrash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashnamesearch = prefs.getString('trashname') ?? '';

    final response = await http.get(
      Uri.parse(trashnamesearch.isEmpty
          ? searchtrashs
          : '$searchtrashs?trash_name=$trashnamesearch'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _trash = jsonDecode(response.body);
        _isLoading = false;
      });
    }

    prefs.remove('trashname');
  }

  void _loadMoreItems() {
    setState(() {
      _itemsToShow += 10; // Load 10 more items each time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        backgroundColor: Colors.green[300],
        title: _isSearchClicked
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      controller: _searchBoxController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'ค้นหารายการขยะ'),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _onChangedSearch();
                            _isLoading = true;
                            _loadTrash();
                          });
                        },
                        icon: const Icon(Icons.search))
                  ],
                ))
            : const Text(
                'ค้นหารายการขยะ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearchClicked = !_isSearchClicked;
                  if (!_isSearchClicked) {
                    _searchBoxController.clear();
                  }
                });
              },
              icon: Icon(_isSearchClicked ? Icons.close : Icons.search))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Card(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              child: const Text(
                                'ขยะทั่วไป',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _selectTypeTrash('ขยะทั่วไป');
                                });
                              },
                            ),
                          ),
                          Card(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              child: const Text(
                                'ขยะอินทรีย์',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _selectTypeTrash('ขยะอินทรีย์');
                                });
                              },
                            ),
                          ),
                          Card(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              child: const Text(
                                'ขยะรีไซเคิล',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _selectTypeTrash('ขยะรีไซเคิล');
                                });
                              },
                            ),
                          ),
                          Card(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              child: const Text(
                                'ขยะอันตราย',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _selectTypeTrash('ขยะอันตราย');
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _trash
                                  .where(
                                    (_trash) =>
                                        _trash['status'] == 1 ||
                                        (_trash['status'] == 2 &&
                                            (_userData ==
                                                    _trash['user_id']
                                                        .toString() ||
                                                _userData == '1')),
                                  )
                                  .length <
                              _itemsToShow
                          ? _trash
                              .where(
                                (_trash) =>
                                    _trash['status'] == 1 ||
                                    (_trash['status'] == 2 &&
                                        (_userData ==
                                                _trash['user_id'].toString() ||
                                            _userData == '1')),
                              )
                              .length
                          : _itemsToShow,
                      itemBuilder: (context, index) {
                        final trash = _trash
                            .where(
                              (_trash) =>
                                  _trash['status'] == 1 ||
                                  (_trash['status'] == 2 &&
                                      (_userData ==
                                              _trash['user_id'].toString() ||
                                          _userData == '1')),
                            )
                            .toList()[index];
                        return Card(
                          // status = 1 ผ่านการตรวจสอบและสามารถแสดงให้ดูได้
                          // status = 2 กำลังตรวจสอบ user_id ผู้เพิ่มหรือ admin จะสามารถมองเห็นได้เท่านั้น
                          // status = 3 ถูกลบจะไม่สามารถมองเห็นได้
                          // เมื่อ trash column status มีค่าเป็น 2 (กำลังตรวจสอบ) พื้นหลังจะเปลี่ยนสีเป็นสีเหลือง
                          color: trash['status'] == 2
                              ? Colors.yellow[200]
                              : trash['status'] == 3
                                  ? Colors.red
                                  : null,
                          // ทำการตรวจสอบหาก status เป็น 2 จะไม่แสดงผลออกมา
                          // แสดงผลเฉพาะ รายการขยะที่มี status เป็น 1
                          // หากเป็น 2 จะทำการตรวจสอบอีกครั้งว่า user_id ตรงกับรายการขยะหรือไม่
                          child: ListTile(
                            title: Text(trash['trash_name']),
                            subtitle: Text(trash['trash_type']),
                            leading: trash['trash_pic'] != null
                                ? const Icon(Icons.error_outline)
                                : const Icon(Icons.error),
                            trailing:
                                _userData == trash['user_id'].toString() ||
                                        _userData == '1'
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              getTrashUpdateInfo(trash);
                                            },
                                            icon: const Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              deleteTrashWindow(trash);
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ],
                                      )
                                    : null,
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      insetPadding: const EdgeInsets.all(16),
                                      title: const Text(
                                        'รายละเอียดขยะ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 600,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trash['trash_name'],
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: trash['trash_pic'] !=
                                                          null
                                                      ? Image.memory(
                                                          height: 300,
                                                          width: 300,
                                                          base64Decode(trash[
                                                              'trash_pic']),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : const Icon(Icons.image),
                                                ),
                                              ),
                                              const Text(
                                                'รายละเอียดขยะ',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child:
                                                      Text(trash['trash_des']),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              const Text(
                                                'วิธีการกำจัด',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 300,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            onPressed:
                                                Navigator.of(context).pop,
                                            child: const Text('ปิด'))
                                      ],
                                    )),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_trash.length > _itemsToShow)
                    ElevatedButton(
                      onPressed: _loadMoreItems,
                      child: const Text('โหลดข้อมูลเพิ่ม'),
                    ),
                ],
              ),
            ),
    );
  }
}
