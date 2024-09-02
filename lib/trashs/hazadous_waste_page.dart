import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';

class HazadousWaste extends StatefulWidget {
  const HazadousWaste({super.key});

  @override
  State<HazadousWaste> createState() => _HazadousWasteState();
}

class _HazadousWasteState extends State<HazadousWaste>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> _trash = [];
  List<dynamic> _trashsearch = [];
  bool _isSearching = false;
  File? _imageFile;
  String? _userData = '';

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
    _userData = prefs.getString('user_id');

    try {
      final response = await http.get(
        Uri.parse('$searchtrashs?trash_type=ขยะอันตราย'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> trashs = jsonDecode(response.body);
        setState(() {
          _trash = trashs;
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

  Future<void> _searchfortrash() async {
    String trashnamesearch = searchController.text;

    if (trashnamesearch.isEmpty) {
      _trashsearch = [];
      setState(() {
        _isSearching = false;
        // print(_isSearching);
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$searchtrashs?trash_name=$trashnamesearch&trash_type=ขยะอันตราย'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> searchResults = jsonDecode(response.body);
        _trashsearch = searchResults;
        setState(() {
          _isSearching = true;
          // print(_isSearching);
        });
      } else {
        // Handle error
        _trashsearch = [];
        setState(() {
          _isSearching = false;
        });
      }
    } catch (error) {
      // Handle network or other errors
      _trashsearch = [];
      setState(() {
        _isSearching = false;
      });
    }
  }

  final _formValidator = GlobalKey<FormState>();
  final trashnameController = TextEditingController();
  final trashtypeController = TextEditingController();
  final trashdesController = TextEditingController();
  final searchController = TextEditingController();
  String? trashtypePicker;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _image;

  Future<void> _trashRegister() async {
    if (_formValidator.currentState!.validate()) {
      String trashname = trashnameController.text;
      String trashtype = trashtypePicker!;
      String trashdes = trashdesController.text;
      String? basae64Image = _image != null ? base64Encode(_image!) : null;

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
          'trash_pic': basae64Image,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        // Load trash items if necessary
        await _loadTrashs();
        Navigator.of(context).pop();
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
          _imageFile = File(pickedFile.path);
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
              'ขยะอันตราย',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'รายละเอียด',
                ),
                Tab(
                  text: 'รายการขยะอันตราย',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              const DetailedHazadousWaste(),
              listOfGeneral(),
            ],
          ),
          floatingActionButton: _tabController!.index == 1
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  onPressed: () {
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                          labelText: 'กรอกชื่อขยะ',
                                          hintText: 'ชื่อขยะ',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                          labelText: 'เลือกประเภทขยะ',
                                          hintText: 'ขยะอันตราย',
                                          border: OutlineInputBorder()),
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
                                          labelText: 'กรอกรายละเอียดขยะ',
                                          hintText: 'รายละเอียดขยะ',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    _imageFile != null
                                        ? Column(
                                            children: [
                                              Stack(children: [
                                                Image.file(
                                                  _imageFile!,
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
                                                        _imageFile = null;
                                                        _image = null;
                                                      });
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
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
                                                child:
                                                    const Text('เพิ่มรูปภาพ'))
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

  Widget listOfGeneral() {
    //TODO list
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
                    hintText: 'ค้นหารายการขยะอันตราย',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: _searchfortrash, icon: const Icon(Icons.search))
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              'รายการขยะอันตราย',
              style: TextStyle(fontSize: 24),
            ),
            // list รายการด้านล่าง
            const SizedBox(
              height: 10,
            ),
            _isSearching
                ? _trashsearch.isNotEmpty
                    ? ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _trashsearch
                            .where(
                              (_trashsearch) =>
                                  _trashsearch['status'] == 1 ||
                                  (_trashsearch['status'] == 2 &&
                                      (_userData ==
                                              _trashsearch['user_id']
                                                  .toString() ||
                                          _userData == '1')),
                            )
                            .length,
                        itemBuilder: (context, index) {
                          final trash = _trashsearch
                              .where(
                                (_trashsearch) =>
                                    _trashsearch['status'] == 1 ||
                                    (_trashsearch['status'] == 2 &&
                                        (_userData ==
                                                _trashsearch['user_id']
                                                    .toString() ||
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
                                  ? const Icon(Icons.error_outline)
                                  : const Icon(Icons.error),
                              trailing:
                                  _userData == trash['user_id'].toString() ||
                                          _userData == '1'
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () => (trash: trash),
                                              icon: const Icon(Icons.edit),
                                            ),
                                            IconButton(
                                              onPressed: () async {},
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
                                                        : const Icon(
                                                            Icons.image),
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
                        })
                    : const Text('ไม่พบรายการขยะ')
                : ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _trash
                        .where(
                          (_trash) =>
                              _trash['status'] == 1 ||
                              (_trash['status'] == 2 &&
                                  (_userData == _trash['user_id'].toString() ||
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
                              ? const Icon(Icons.error_outline)
                              : const Icon(Icons.error),
                          trailing: _userData == trash['user_id'].toString() ||
                                  _userData == '1'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => (trash: trash),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {},
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
                                      width: MediaQuery.of(context).size.width,
                                      height: 600,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trash['trash_name'],
                                              style:
                                                  const TextStyle(fontSize: 18),
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
                                                        base64Decode(
                                                            trash['trash_pic']),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(Icons.image),
                                              ),
                                            ),
                                            const Text(
                                              'รายละเอียดขยะ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(trash['trash_des']),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            const Text(
                                              'วิธีการกำจัด',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
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
                                          onPressed: Navigator.of(context).pop,
                                          child: const Text('ปิด'))
                                    ],
                                  )),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class DetailedHazadousWaste extends StatefulWidget {
  const DetailedHazadousWaste({super.key});

  @override
  State<DetailedHazadousWaste> createState() => _DetailedHazadousWasteState();
}

class _DetailedHazadousWasteState extends State<DetailedHazadousWaste> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ขยะอันตราย',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
                splashColor: Colors.amber,
                onTap: () {},
                child: const SizedBox(
                    height: 300,
                    width: 300,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ขยะอันตราย (Hazardous Waste)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '    คือขยะที่มีการปนเปื้อนสารเคมีและเป็นอันตรายต่อสิ่งแวดล้อมหรือสามารถติดไฟได้ง่าย ต้องมีการกำจัดอย่างถูกวิธีและไม่สามารถทิ้งรวมกับขยะประเภทอื่นได้ ตัวอย่างของขยะประเภทขยะอันตรายเช่น หลอดไฟ ถ่านไฟฉาย วัตถุไวไฟ ยาที่หมดอายุ สารพิษ อุปกรณ์อิเล็กทรอนิกส์ โดยประเทศไทยจำแนกให้ขยะประเภทขยะอันตรายสามารถทิ้งได้ในที่ถังขยะที่มีสีแดง',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ))),
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
                child: const SizedBox(
                    height: 300,
                    width: 300,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '    ขยะอันตรายส่วนใหญ่มักจะมีผลกระทบต่อสุขภาพต่อผู้เก็บขยะได้ จึงต้องระวังเป็นอย่างมากในการนำไปทิ้ง วิธีการปิดถุงที่มีขยะให้มิดชิดและเขียนกำกับบนถุงไว้ว่าเป็นขยะอันตราย',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ))),
          ),
        ],
      ),
    ));
  }
}
