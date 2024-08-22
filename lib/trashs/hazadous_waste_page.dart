import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';

class hazadousWaste extends StatefulWidget {
  const hazadousWaste({super.key});

  @override
  State<hazadousWaste> createState() => _hazadousWasteState();
}

class _hazadousWasteState extends State<hazadousWaste>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> _trash = [];
  List<dynamic> _trashsearch = [];
  bool _isSearching = false;

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
    try {
      final response = await http.get(
        Uri.parse(
            'https://zerowasteheroapp.com/search/trashs?trash_type=ขยะอันตราย'),
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
            'https://zerowasteheroapp.com/search/trashs?trash_name=$trashnamesearch&trash_type=ขยะอันตราย'),
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
          'trash_pic': _image,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        // Load trash items if necessary
        await _loadTrashs();
        Navigator.of(context).pop();
      } else {
        // Handle error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to register trash.'),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.green[100],
          appBar: AppBar(
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
              tabs: [
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
              detailedGeneral(),
              listOfGeneral(),
            ],
          ),
          floatingActionButton: _tabController!.index == 1
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                          child: Form(
                            key: _formValidator,
                            child: Column(
                              children: [
                                const Text('data'),
                                const SizedBox(
                                  height: 16,
                                ),
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
                                  value: trashtypePicker,
                                  items: [
                                    'ขยะทั่วไป',
                                    'ขยะอินทรีย์',
                                    'ขยะรีไซเคิล',
                                    'ขยะอันตราย'
                                  ]
                                      .map((label) => DropdownMenuItem(
                                            child: Text(label),
                                            value: label,
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
                                ElevatedButton(
                                    onPressed: _pickImage,
                                    child: Text('เพิ่มรูปภาพ')),
                                TextButton(
                                    onPressed: _trashRegister,
                                    child: const Text('ตกลง'))
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                )
              : null),
    );
  }

  Widget detailedGeneral() {
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
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tab,
                            size: 50,
                          ),
                          Text(
                            'ข้อมูล',
                            textAlign: TextAlign.center,
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
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_bar,
                            size: 50,
                          ),
                          Text(
                            'ข้อมูล',
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ))),
          ),
        ],
      ),
    ));
  }

  Widget listOfGeneral() {
    //TODO list
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                      shrinkWrap: true,
                      itemCount: _trashsearch.length,
                      itemBuilder: (context, index) {
                        final trash = _trashsearch[index];
                        return Card(
                          child: ListTile(
                            title: Text(trash['trash_name']),
                            subtitle: Text(trash['trash_type']),
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('รายละเอียดขยะ'),
                                      content: Column(
                                        children: [
                                          Text(trash['trash_name']),
                                          trash['trash_pic'] != null
                                              ? Image.memory(Uint8List.fromList(
                                                  trash['trash_pic']))
                                              : Icon(Icons.image),
                                          Text(trash['trash_des'])
                                        ],
                                      ),
                                    )),
                          ),
                        );
                      })
                  : const Text('ไม่พบรายการขยะ')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _trash.length,
                  itemBuilder: (context, index) {
                    final trash = _trash[index];
                    return Card(
                      child: ListTile(
                        title: Text(trash['trash_name']),
                        subtitle: Text(trash['trash_type']),
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('รายละเอียดขยะ'),
                                  content: Column(
                                    children: [
                                      Text(trash['trash_name']),
                                      trash['trash_pic'] != null
                                          ? Image.memory(Uint8List.fromList(
                                              trash['trash_pic']))
                                          : Icon(Icons.image),
                                      Text(trash['trash_des'])
                                    ],
                                  ),
                                )),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget listGeneralWasteItem(
    String nameoflist,
  ) {
    return Card(
      shadowColor: Colors.black,
      elevation: 2,
      child: ListTile(
        title: Text(nameoflist),
        onTap: () {},
        splashColor: Colors.amber,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
