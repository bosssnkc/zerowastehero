import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/custom_icons_icons.dart';

class RecycleWaste extends StatefulWidget {
  const RecycleWaste({super.key});

  @override
  State<RecycleWaste> createState() => _RecycleWasteState();
}

class _RecycleWasteState extends State<RecycleWaste>
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

  @override
  void initState() {
    super.initState();
    _loadTrashs();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {}); // Update the UI when the tab changes
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Future<void> _loadTrashs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashnamesearch = searchController.text;
    _userData = prefs.getString('user_id');
    guestToken = prefs.getString('guestToken');

    try {
      final response = await http.get(
        Uri.parse(trashnamesearch.isEmpty
            ? '$searchtrashs?trash_type=ขยะรีไซเคิล'
            : '$searchtrashs?trash_name=$trashnamesearch&trash_type=ขยะรีไซเคิล'),
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
            title: const Text('Error'),
            content: const Text('Failed to load trashs.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
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
          title: const Text('Error'),
          content: const Text('Failed to load trashs.'),
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
              'ขยะรีไซเคิล',
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
                text: 'รายการขยะรีไซเคิล',
              ),
            ]),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              const DetailedRecycleWaste(),
              listOfRecycles(),
            ],
          ),
          floatingActionButton: _tabController!.index == 1
              ? guestToken != null
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
                                            labelText: 'กรอกชื่อขยะ',
                                            hintText: 'ชื่อขยะ',
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            labelText: 'เลือกประเภทขยะ',
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

  Widget listOfRecycles() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    hintText: 'ค้นหารายการขยะรีไซเคิล',
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
              'รายการขยะรีไซเคิล',
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
                                  (_trash['status'] == 2 &&
                                      (_userData ==
                                              _trash['user_id'].toString() ||
                                          _userData == '1')),
                            )
                            .length,
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
                              onTap: () {
                                print(trash);
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          title: const Text(
                                            'รายละเอียดขยะ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        trash['trash_name'],
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  trash['trash_price'] != null
                                                      ? Row(
                                                          children: [
                                                            const Text(
                                                              'ราคา ',
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              '${trash['trash_price'].toString()} บาท/กก.',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      : const Text(
                                                          'ไม่มีราคา',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                  const SizedBox(
                                                    height: 16,
                                                  ),
                                                  Card(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          trash['trash_pic'] !=
                                                                  null
                                                              ? Image.memory(
                                                                  height: 300,
                                                                  width: 300,
                                                                  base64Decode(
                                                                      trash[
                                                                          'trash_pic']),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : const Center(
                                                                  child: Column(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .image_not_supported,
                                                                        size:
                                                                            120,
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
                                        ));
                              },
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

class DetailedRecycleWaste extends StatefulWidget {
  const DetailedRecycleWaste({super.key});

  @override
  State<DetailedRecycleWaste> createState() => _DetailedRecycleWasteState();
}

class _DetailedRecycleWasteState extends State<DetailedRecycleWaste> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ขยะรีไซเคิล',
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
                  padding: EdgeInsets.all(16),
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
                                CustomIcons.recycle_waste_bin,
                                size: 100,
                                color: Colors.yellow,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .copyWith(fontSize: 16),
                                children: const [
                                  TextSpan(
                                    text: 'ขยะรีไซเคิล (Recycle Waste)\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                      text:
                                          '    คือขยะที่มีมูลค่าโดยสามารถนำมานำกลับมาใช้งานเป็นวัสดุรีไซเคิล เพื่อนำไปผลิตเป็นอุปกรณ์ใหม่ได้เช่น ขาเทียมแขนเทียมสำหรับผู้พิการ ขวดแก้วที่ใส่บรรจุภัณฑ์ ขวดน้ำพลาสติกรีไซเคิลที่ใส่บรรจุภัณฑ์ ตัวอย่างของขยะประเภทขยะรีไซเคิลเช่น ขวดน้ำพลาสติก เศษแก้ว กระป๋องอะลูมิเนียม โดยประเทศไทยจำแนกขยะประเภทขยะรีไซเคิลสามารถทิ้งได้ในถังขยะที่มีสีเหลือง\n')
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
              onTap: () {},
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
                splashColor: Colors.blue,
                onTap: () {},
                child: SizedBox(
                    // height: 300,
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                      text:
                                          '    ขยะรีไซเคิลที่สามารถนำไปเข้าสู่กระบวนการรีไซเคิลได้ และต้องสะอาดและไม่มีการปนเปื้อนเศษอาหารหรือสารเคมีที่มีอันตราย จึงสามารถนำไปเข้าสู่กระบวนการรีไซเคิลได้')
                                ]),
                          ),
                        ],
                      ),
                    ))),
          ),
        ],
      ),
    ));
  }
}
