import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
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
  // late TextEditingController _trashNameController;
  // late TextEditingController _trashDesController;
  final _trashNameController = TextEditingController();
  final _trashDesController = TextEditingController();
  // late TextEditingController _trashTypeController;
  // late TextEditingController _trashTypeController;
  // late TextEditingController _trashNameController;
  // late TextEditingController _trashDesController;
  String? trashtypePicker;

  @override
  void initState() {
    super.initState();
    _loadTrash();
    _loadUserData();
  }

  Future<void> getTrashUpdateInfo(dynamic trashlist) async {
    print(trashlist);
    setState(() {
      _trashNameController.text = trashlist['trash_name'];
      _trashDesController.text = trashlist['trash_des'];
      trashtypePicker = trashlist['trash_type'];
    });
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                ElevatedButton(onPressed: () {}, child: const Text('บันทึก')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ยกเลิก'))
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
                                  value: label, child: Text(label)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              trashtypePicker = value;
                            });
                          }),
                      const SizedBox(height: 20),
                      TextFormField(
                        maxLines: 7,
                        controller: _trashDesController,
                        decoration: const InputDecoration(
                          labelText: 'รายละเอียดขยะ',
                        ),
                      ),
                      const SizedBox(height: 20),
                      trashlist['trash_pic'] != null
                          ? Stack(
                              children: [
                                Image.memory(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  base64Decode(trashlist['trash_pic']),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.update),
                                  ),
                                )
                              ],
                            )
                          : const Icon(Icons.image_not_supported),
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> updateTrash() async {
    try {
      final response = await http.put(
        Uri.parse('http://google.com'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('อัพเดทเรียบร้อย')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('อัพเดทไม่สำเร็จ')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ERROR')));
    }
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
