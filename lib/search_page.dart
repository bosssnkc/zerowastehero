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
  final _formValidator = GlobalKey<FormState>();
  final trashnameController = TextEditingController();
  final trashtypeController = TextEditingController();
  final trashdesController = TextEditingController();
  final searchController = TextEditingController();
  String? guestToken = '';
  final trashhowController = TextEditingController();
  final _trashHowController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrash();
    _loadUserData();
    setState(() {});
  }

  Future<void> _trashRegister() async {
    if (_formValidator.currentState!.validate()) {
      String trashname = trashnameController.text;
      String trashtype = trashtypePicker!;
      String trashdes = trashdesController.text;
      String trashhow = trashhowController.text;
      String? base64Image = _image != null ? base64Encode(_image!) : null;

      // Fetch the user_id from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      // Send data to API
      final response = await http.post(
        Uri.parse(addTrash),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'trash_name': trashname,
          'trash_type': trashtype,
          'trash_des': trashdes,
          'trash_how': trashhow,
          'trash_pic': base64Image,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        // Load trash items if necessary
        await _loadTrash();
        Navigator.of(context).pop();
        _textFieldClear();
      } else {
        // Handle error
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
    }
  }

  Future<void> _textFieldClear() async {
    setState(() {
      trashnameController.clear();
      trashdesController.clear();
      trashtypePicker = null;
      _image = null;
    });
  }

  Future<void> getTrashUpdateInfo(dynamic trashlist) async {
    print(trashlist);
    setState(() {
      _trashNameController.text = trashlist['trash_name'];
      _trashDesController.text = trashlist['trash_des'];
      _trashHowController.text = trashlist['trash_how'] ?? '';
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
                // ฟังก์ชันการอัพเดทรายการขยะโดยทำการตรวจสอบความถูกต้องของฟอร์มก่อน
                if (_formValidator.currentState!.validate()) {
                  final updatedTrash = {
                    'trash_name': _trashNameController.text,
                    'trash_des': _trashDesController.text,
                    'trash_how': _trashHowController.text,
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
            child: Form(
              key: _formValidator,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
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
                      maxLines: 3,
                      controller: _trashDesController,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดขยะ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรอกรายละเอียดขยะ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 3,
                      controller: _trashHowController,
                      decoration: const InputDecoration(
                          labelText: 'วิธีการกำจัด',
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรอกวิธีการกำจัด';
                        }
                        return null;
                      },
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
                        ? Card(
                            child: Stack(
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
                            ),
                          )
                        : const Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 120,
                                    ),
                                    Text(
                                      'ไม่มีรูปภาพ',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
          'Content-Type': 'application/json; charset=UTF-8',
          'App-Source': appsource
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
    guestToken = prefs.getString('guestToken');
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
        'App-Source': appsource
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
      floatingActionButton: guestToken != null
          ? null
          : FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              onPressed: () {
                _textFieldClear();
                showDialog(
                  context: context,
                  builder: (_) => StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      insetPadding: const EdgeInsets.all(16),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      title: const Text('เพิ่มรายการขยะชิ้นใหม่'),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: Form(
                          key: _formValidator,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: trashnameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรอกชื่อขยะ';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'ชื่อขยะ',
                                    hintText: 'กรอกชื่อขยะ',
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'เลือกประเภทขยะ',
                                    hintText: 'ขยะทั่วไป',
                                  ),
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
                                  validator: (value) {
                                    if (value == null) {
                                      return 'กรุณาเลือกชนิดของขยะ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: trashdesController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรอกรายละเอียดขยะ';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'รายละเอียดขยะ',
                                      hintText: 'กรอกรายละเอียดขยะ',
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: trashhowController,
                                  decoration: const InputDecoration(
                                      labelText: 'วิธีการกำจัด',
                                      hintText: 'กรอกวิธีการกำจัด'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรอกวิธีการกำจัด';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                _image != null
                                    ? Column(
                                        children: [
                                          Stack(children: [
                                            Image.memory(
                                              _image!,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _image = null;
                                                  });
                                                },
                                                icon: const Icon(Icons.close),
                                              ),
                                            ),
                                          ]),
                                          ElevatedButton(
                                              onPressed: () async {
                                                await _pickImage();
                                                setState(() {});
                                              },
                                              child:
                                                  const Text('เปลี่ยนรูปภาพ'))
                                        ],
                                      )
                                    : Column(children: [
                                        const Text('ไม่ได้เลือกรูปภาพ'),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await _pickImage();
                                              setState(() {});
                                            },
                                            child: const Text('เพิ่มรูปภาพ'))
                                      ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: _trashRegister,
                          child: const Text(
                            'เพิ่มรายการ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              _textFieldClear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('ยกเลิก'))
                      ],
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/zwh_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
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
                                                  _trash['user_id']
                                                      .toString() ||
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
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        height: 48,
                                        width: 48,
                                        base64Decode(trash['trash_pic']),
                                        fit: BoxFit.cover,
                                      ),
                                    )
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'ชื่อขยะ ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      trash['trash_name'],
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                const Text(
                                                  'รูปภาพ',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Card(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: trash['trash_pic'] !=
                                                            null
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.memory(
                                                              height: 300,
                                                              width: 300,
                                                              base64Decode(trash[
                                                                  'trash_pic']),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : const Center(
                                                            child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size: 120,
                                                              ),
                                                              Text(
                                                                'ไม่มีรูปภาพ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              )
                                                            ],
                                                          )),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 8,
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        trash['trash_des']),
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
                                                Card(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          trash['trash_how'] !=
                                                                  null
                                                              ? Text(trash[
                                                                  'trash_how'])
                                                              : const Text(
                                                                  'Null')),
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
      ),
    );
  }
}
