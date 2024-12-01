import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/custom_icons_icons.dart';

class CompostableWaste extends StatefulWidget {
  const CompostableWaste({super.key});

  @override
  State<CompostableWaste> createState() => _CompostableWasteState();
}

class _CompostableWasteState extends State<CompostableWaste>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> _trash = [];
  String? _userData = '';
  final _formValidator = GlobalKey<FormState>();
  final trashnameController = TextEditingController();
  final trashtypeController = TextEditingController();
  final trashdesController = TextEditingController();
  final trashhowController = TextEditingController();
  final searchController = TextEditingController();
  String? trashtypePicker;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _image;
  bool _isLoading = true;
  String? guestToken = '';
  int _selectedIndex = 0;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _loadTrashs();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _getTabIndex(_tabController!.index);
      }); // Update the UI when the tab changes
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  int _getTabIndex(int index) {
    if (index == 0) {
      return 0;
    } else {
      return 2;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0 || index == 2) {
        _tabController!.animateTo(
            index == 0 ? 0 : 1); // อัปเดต Tab ตามการเลือก BottomNavigationBar
      } else if (index == 1) {
        Navigator.of(context)
            .popUntil((route) => route.isFirst); // กลับไปยังหน้าแรก
      }
    });
  }

  Future<void> _loadTrashs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashnamesearch = searchController.text;
    _userData = prefs.getString('user_id');
    guestToken = prefs.getString('guestToken');
    _userRole = prefs.getInt('role');

    try {
      final response = await http.get(
        Uri.parse(trashnamesearch.isEmpty
            ? '$searchtrashs?trash_type=ขยะอินทรีย์'
            : '$searchtrashs?trash_name=$trashnamesearch&trash_type=ขยะอินทรีย์'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'App-Source': appsource
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> trashs = jsonDecode(response.body);
        setState(() {
          _trash = trashs;
          _isLoading = false;
        });
      } else {
        // Handle error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load trashs.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      // Handle network or other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load trashs.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
        await _loadTrashs();
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('เพิ่มรายการขยะเรียบร้อย'),
            content: Text('เพิ่มรายการขยะเรียบร้อย'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
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

  Future<void> _textFieldClear() async {
    setState(() {
      trashnameController.clear();
      trashdesController.clear();
      trashhowController.clear();
      trashtypePicker = null;
      _image = null;
    });
  }

  Future<void> getTrashUpdateInfo(dynamic trashlist) async {
    print(trashlist);
    setState(() {
      trashnameController.text = trashlist['trash_name'];
      trashdesController.text = trashlist['trash_des'];
      trashhowController.text = trashlist['trash_how'] ?? '';
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
                    'trash_name': trashnameController.text,
                    'trash_des': trashdesController.text,
                    'trash_how': trashhowController.text,
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

                _loadTrashs();
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
                _loadTrashs();
                _textFieldClear();
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
                      controller: trashnameController,
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
                      decoration: const InputDecoration(
                        labelText: 'ประเภทขยะ',
                        hintText: 'ระบุประเภทขยะ',
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
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 3,
                      controller: trashdesController,
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
                      controller: trashhowController,
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
                      _loadTrashs();
                    },
                    child: const Text('ยืนยันการลบ')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadTrashs();
                    },
                    child: const Text('ยกเลิก'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
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
            title: const Text(
              'ขยะอินทรีย์',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(controller: _tabController, tabs: const [
              Tab(
                text: 'รายละเอียด',
              ),
              Tab(
                text: 'รายการขยะอินทรีย์',
              ),
            ]),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/zwh_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                const DetailedCompostableWaste(),
                listOfCompostable(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(CustomIcons.compostable_waste_bin),
                  label: 'ข้อมูลขยะอินทรีย์'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'รายการขยะอินทรีย์'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          floatingActionButton: _tabController!.index == 1
              ? _userRole != 1
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextFormField(
                                          controller: trashnameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                              labelText: 'ประเภทขยะ',
                                              hintText: 'ระบุประเภทขยะ'),
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
                                              return 'กรุณาเลือกประเภทของขยะ';
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
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'กรอกรายละเอียดขยะ';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'รายละเอียดขยะ',
                                            hintText: 'กรอกรายละเอียดขยะ',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: trashhowController,
                                          decoration: const InputDecoration(
                                              labelText: 'วิธีการกำจัด',
                                              hintText: 'กรอกวิธีการกำจัด'),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                                      width:
                                                          MediaQuery.of(context)
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
                                                        icon: const Icon(
                                                            Icons.close),
                                                      ),
                                                    ),
                                                  ]),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        await _pickImage();
                                                        setState(() {});
                                                      },
                                                      child: const Text(
                                                          'เปลี่ยนรูปภาพ'))
                                                ],
                                              )
                                            : Column(children: [
                                                const Text('ไม่ได้เลือกรูปภาพ'),
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      await _pickImage();
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        'เพิ่มรูปภาพ'))
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                    )
              : null),
    );
  }

  Widget listOfCompostable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหารายการขยะอินทรีย์',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _loadTrashs();
                      });
                    },
                    icon: const Icon(Icons.search))
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              'รายการขยะอินทรีย์',
              style: TextStyle(fontSize: 24),
            ),
            // list รายการด้านล่าง
            const SizedBox(
              height: 10,
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : _trash.isNotEmpty
                    ? ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _trash
                            .where(
                              (_trash) =>
                                  _trash['status'] == 1 ||
                                  (_trash['status'] != 1 &&
                                      (_userData == '1' || _userRole == 1)),
                            )
                            .length,
                        itemBuilder: (context, index) {
                          final trash = _trash
                              .where(
                                (_trash) =>
                                    _trash['status'] == 1 ||
                                    (_trash['status'] != 1 &&
                                      (_userData == '1' || _userRole == 1)),
                              )
                              .toList()[index];
                          return Card(
                            color: trash['status'] == 2
                                ? Colors.yellow[200]
                                : trash['status'] == 3
                                    ? Colors.red
                                    : null,
                            child: ListTile(
                              title: Text(trash['trash_name']),
                              subtitle: Text(trash['trash_type']),
                              leading: trash['trash_pic'] != null
                                  ? Image.memory(
                                      height: 48,
                                      width: 48,
                                      base64Decode(trash['trash_pic']),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.error),
                              trailing: _userRole == 1 && _userData == '1'
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
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                                Card(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: trash['trash_pic'] !=
                                                            null
                                                        ? Image.memory(
                                                            height: 300,
                                                            width: 300,
                                                            base64Decode(trash[
                                                                'trash_pic']),
                                                            fit: BoxFit.cover,
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
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16,
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
                                                      trash['trash_des'],
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
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
                                                              ? Text(
                                                                  trash[
                                                                      'trash_how'],
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              : const Text(
                                                                  'Null')),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.red),
                                              onPressed:
                                                  Navigator.of(context).pop,
                                              child: const Text('ปิด'))
                                        ],
                                      )),
                            ),
                          );
                        })
                    : const Text('ไม่พบรายการขยะ')
          ],
        ),
      ),
    );
  }
}

class DetailedCompostableWaste extends StatefulWidget {
  const DetailedCompostableWaste({super.key});

  @override
  State<DetailedCompostableWaste> createState() =>
      _DetailedCompostableWasteState();
}

class _DetailedCompostableWasteState extends State<DetailedCompostableWaste> {
  final YoutubePlayerController _playerController = YoutubePlayerController(
    initialVideoId: 'LHevSNtyvU4', //กำหนด YouTube VideoID ให้กับ ตัวเล่น
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
      disableDragSeek: false,
      loop: false,
      isLive: false,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ขยะอินทรีย์',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            'คลิกเพื่ออ่านต่อ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 39, 73, 133),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Icon(
                                  CustomIcons.compostable_waste_bin,
                                  size: 100,
                                  color: Colors.green,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'ขยะอินทรีย์ (Compostable Waste)\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            '    หรืออีกชื่อคือขยะเปียก คือขยะที่สามารถย่อยสลายได้ง่ายตามธรรมชาติ มีความชื้นและส่งกลิ่นเหม็น ขยะประเภทนี้สามารถนำไปทำเป็นปุ๋ยหมักชีวภาพได้ ตัวอย่างของขยะประเภทขยะเปียกเช่น เศษใบไม้ เศษอาหาร เศษเนื้อสัตว์ เปลือกผลไม้ โดยประเทศไทยจำแนกให้ขยะประเภทขยะเปียกสามารถทิ้งได้ในถังขยะที่มีสีเขียว\n'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      insetPadding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                      title: const Text('ขยะอินทรีย์'),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RichText(
                                // textAlign: TextAlign.justify,
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'ขยะอินทรีย์ (Compostable Waste)\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            '    หรืออีกชื่อคือขยะเปียก คือขยะที่สามารถย่อยสลายได้ง่ายตามธรรมชาติ มีความชื้นและส่งกลิ่นเหม็น ขยะประเภทนี้สามารถนำไปทำเป็นปุ๋ยหมักชีวภาพได้ ตัวอย่างของขยะประเภทขยะเปียกเช่น เศษใบไม้ เศษอาหาร เศษเนื้อสัตว์ เปลือกผลไม้ โดยประเทศไทยจำแนกให้ขยะประเภทขยะเปียกสามารถทิ้งได้ในถังขยะที่มีสีเขียวดังรูปภาพดังนี้\n'),
                                  ],
                                ),
                              ),
                              Center(
                                  child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: const Image(
                                  image: AssetImage(
                                      'assets/image/green_trash.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                              const Text(
                                'ที่มา: hospitalitythailand.com',
                                textAlign: TextAlign.center,
                              ),
                              RichText(
                                text: TextSpan(
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontSize: 16),
                                    children: const [
                                      TextSpan(
                                          text: 'ปัญหาของขยะอินทรีย์\n',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              '    แม้ว่าขยะอินทรีย์จะสามารถย่อยสลายได้ แต่หากไม่มีการจัดการที่เหมาะสม เช่น การนำไปฝังกลบในหลุมขยะทั่วไป ขยะอินทรีย์จะปล่อยก๊าซมีเทน (Methane) ซึ่งเป็นก๊าซเรือนกระจกที่มีความรุนแรงมากกว่าคาร์บอนไดออกไซด์ ดังนั้นการจัดการขยะอินทรีย์ด้วยวิธีที่เหมาะสม เช่น การทำปุ๋ยหมักด้วยถังหมัก เป็นวิธีการที่ช่วยลดปริมาณขยะที่จะนำไปทิ้งและสามารถนำปุ๋ยหมักไปใช้ประโยชน์ในทางการเกษตรและผักสวนครัวหลังบ้านได้\n'),
                                    ]),
                              ),
                              YoutubePlayer(
                                controller: _playerController,
                                showVideoProgressIndicator: true,
                                onReady: () {
                                  print('Player is ready.');
                                },
                              ),
                              const Text(
                                  textAlign: TextAlign.center,
                                  'ที่มา: กรมการเปลี่ยนแปลงสภาพภูมิอากาศและสิ่งแวดล้อม'),
                              const SizedBox(
                                height: 8,
                              ),
                              RichText(
                                  text: TextSpan(
                                      style: DefaultTextStyle.of(context)
                                          .style
                                          .copyWith(fontSize: 16),
                                      children: const [
                                    TextSpan(
                                      text: 'วิธีการกำจัดขยะอินทรีย์\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            '    1. การทำปุ๋ยหมัก (Composting): ขยะอินทรีย์สามารถนำมาทำปุ๋ยหมัก ซึ่งเป็นกระบวนการย่อยสลายตามธรรมชาติ และได้สารอาหารที่มีประโยชน์สำหรับดิน โดยกระบวนการนี้ช่วยลดปริมาณขยะที่จะต้องนำไปฝังกลบ\n'),
                                    TextSpan(
                                        text:
                                            '    2. การผลิตก๊าซชีวภาพ (Biogas): ขยะอินทรีย์ที่มีสารอินทรีย์สูง เช่น เศษอาหาร สามารถนำไปใช้ผลิตก๊าซชีวภาพ ซึ่งเป็นพลังงานสะอาดที่สามารถใช้ทดแทนพลังงานจากฟอสซิลได้\n'),
                                    TextSpan(
                                        text:
                                            '    3. การคัดแยกขยะอินทรีย์: การแยกขยะอินทรีย์ออกจากขยะทั่วไปตั้งแต่ต้นทาง เช่น ที่บ้านเรือนหรือร้านอาหาร จะช่วยเพิ่มประสิทธิภาพในการจัดการขยะและลดการปนเปื้อนกับขยะที่ย่อยสลายไม่ได้\n'),
                                  ])),
                              const Text(
                                  'ที่มา: กรมควบคุมมลพิษ. (2564). รายงานสถานการณ์มลพิษของประเทศไทย')
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'วิธีการกำจัด',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                  splashColor: Colors.green,
                  onTap: () {},
                  child: SizedBox(
                      height: 250,
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                      style: DefaultTextStyle.of(context)
                                          .style
                                          .copyWith(fontSize: 16),
                                      children: const [
                                    TextSpan(
                                        text: 'การคัดแยกขยะอันทรีย์\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            '    ทำการคัดแยกขยะอินทรีย์เช่นเศษอาหารออกจากขยะทั่วไปเพราะเศษอาหารนั้นสามารถย่อยสลายได้อาจทำให้ส่งกลิ่นไม่พึงประสงค์ภายในถังขยะหากทำการทิ้งรวม\n\n'),
                                    TextSpan(
                                        text: 'การนำไปหมักปุ๋ย\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            '    ขยะอินทรีย์สามารถย่อยสลายได้ตามธรรมชาติและสามารถนำไปใช้ประโยชน์ทางการเกษตรได้\n\n'),
                                    TextSpan(
                                        text: 'การนำไปทิ้ง\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            '    หากจำเป็นต้องทำการทิ้งลงถังขยะจริงๆควรทิ้งใส่ถุงและปิดปากให้สนิทเพราะอาจส่งกลิ่นไม่พึงประสงค์ได้ โดยสามารถทิ้งได้ที่ถังขยะสีเขียว')
                                  ])),
                            ],
                          ),
                        ),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
