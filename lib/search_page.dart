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

  @override
  void initState() {
    super.initState();
    _loadTrash();
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
      backgroundColor: Colors.green[100],
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
                              child: const Text(
                                'ขยะทั่วไป',
                                style: TextStyle(color: Colors.black),
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
                              child: const Text(
                                'ขยะอินทรีย์',
                                style: TextStyle(color: Colors.black),
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
                              child: const Text(
                                'ขยะรีไซเคิล',
                                style: TextStyle(color: Colors.black),
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
                              child: const Text(
                                'ขยะอันตราย',
                                style: TextStyle(color: Colors.black),
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
                      itemCount: _trash.length < _itemsToShow
                          ? _trash.length
                          : _itemsToShow,
                      itemBuilder: (context, index) {
                        final trash = _trash[index];
                        return Card(
                          child: ListTile(
                            title: Text(trash['trash_name']),
                            subtitle: Text(trash['trash_type']),
                            leading: trash['trash_pic'] != null
                                ? Icon(Icons.error_outline)
                                : Icon(Icons.error),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => (trash: trash),
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () async {},
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
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
                                                  child:
                                                      trash['trash_pic'] != null
                                                          ? Image.memory(
                                                              height: 300,
                                                              width: 300,
                                                              base64Decode(trash[
                                                                  'trash_pic']),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Icon(Icons.image),
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
