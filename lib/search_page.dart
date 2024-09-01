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

  @override
  void initState() {
    super.initState();
    _loadTrash();
    _loadUserData();
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
                                  .where((_trash) => _trash['status'] != 3)
                                  .length <
                              _itemsToShow
                          ? _trash
                              .where((_trash) => _trash['status'] != 3)
                              .length
                          : _itemsToShow,
                      itemBuilder: (context, index) {
                        final trash = _trash
                            .where((_trash) => _trash['status'] != 3)
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
                          child: trash['status'] != 2 && trash['status'] != 3
                              ? ListTile(
                                  title: Text(trash['trash_name']),
                                  subtitle: Text(trash['trash_type']),
                                  leading: trash['trash_pic'] != null
                                      ? const Icon(Icons.error_outline)
                                      : const Icon(Icons.error),
                                  trailing: _userData ==
                                              trash['user_id'].toString() ||
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
                                                            const EdgeInsets
                                                                .all(8.0),
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
                                                                : const Icon(
                                                                    Icons
                                                                        .image),
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
                                                            const EdgeInsets
                                                                .all(8.0),
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
                                )
                              // เงื่อนไข else หาก status ของ trash มีค่าเป็น 2
                              // จะทำการตรวจสอบ user_id อีกครั้งว่าสามารถมองเห็นได้หรือไม่
                              // หาก user_id ไม่ตรงหรือไม่ใช่ admin จะไม่สามารถดูรายการขยะที่อยู่ในสถานะ status = 2 ได้
                              : _userData == trash['user_id'].toString() ||
                                      _userData == '1'
                                  ? ListTile(
                                      title: Text(trash['trash_name']),
                                      subtitle: Text(trash['trash_type']),
                                      leading: trash['trash_pic'] != null
                                          ? const Icon(Icons.error_outline)
                                          : const Icon(Icons.error),
                                      trailing: _userData ==
                                                  trash['user_id'].toString() ||
                                              _userData == '1'
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () =>
                                                      (trash: trash),
                                                  icon: const Icon(Icons.edit),
                                                ),
                                                IconButton(
                                                  onPressed: () async {},
                                                  icon:
                                                      const Icon(Icons.delete),
                                                ),
                                              ],
                                            )
                                          : null,
                                      onTap: () => showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                title: const Text(
                                                  'รายละเอียดขยะ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 600,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          trash['trash_name'],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: trash[
                                                                        'trash_pic'] !=
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
                                                                : const Icon(
                                                                    Icons
                                                                        .image),
                                                          ),
                                                        ),
                                                        const Text(
                                                          'รายละเอียดขยะ',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(trash[
                                                                'trash_des']),
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
                                                                  FontWeight
                                                                      .bold),
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
                                                          Navigator.of(context)
                                                              .pop,
                                                      child: const Text('ปิด'))
                                                ],
                                              )),
                                    )
                                  // หากไม่ตรงเงื่อนไขใดๆเลยจะไม่แสดงผลข้อมูลที่เป็น status 2 ออกมาเลย
                                  : null,
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
