// import 'dart:typed_data';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:zerowastehero/database/database_helper.dart';
import 'package:zerowastehero/database/trash_crud.dart';

class generalWaste extends StatefulWidget {
  const generalWaste({super.key});

  @override
  State<generalWaste> createState() => _genralWasteState();
}

class _genralWasteState extends State<generalWaste> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _trash = [];
  List<Map<String, dynamic>> _trashsearch = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTrashs();
  }

  Future<void> _loadTrashs() async {
    final trashs = await _dbHelper.getGeneralTrash('ขยะทั่วไป');
    setState(() {
      _trash = trashs;
    });
  }

  Future<void> _searchfortrash() async {
    String trashnamesearch = searchController.text;
    if (trashnamesearch.isEmpty) {
      setState(() {
        _trashsearch = [];
        _isSearching = false;
      });
      return;
    }
    final search = await _dbHelper.getGTrashItem(trashnamesearch);
    setState(() {
      _trashsearch = search;
      _isSearching = true;
    });
  }

  final _formValidator = GlobalKey<FormState>();
  final trashnameController = TextEditingController();
  final trashtypeController = TextEditingController();
  final trashdesController = TextEditingController();
  final searchController = TextEditingController();
  String? trashtypePicker;

  Future<void> _trashRegister() async {
    if (_formValidator.currentState!.validate()) {
      String trashname = trashnameController.text;
      String trashtype = trashtypePicker!;
      String trashdes = trashdesController.text;
      // Uint8List trashpic = await getImageBytes();

      final db = DatabaseHelper();
      await db.insertTrash(trashname, trashtype, trashdes);
      await _loadTrashs();

      Navigator.of(context).pop();
    }
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
                'ขยะทั่วไป',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: bodyItem()));
  }

  Widget bodyItem() {
    return SafeArea(
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                text: 'รายละเอียด',
              ),
              Tab(
                text: 'รายการขยะทั่วไป',
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: TabBarView(children: <Widget>[
            detailedGeneral(),
            listOfGeneral(),
          ]))
        ],
      ),
    );
  }

  Widget detailedGeneral() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ขยะทั่วไป',
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
                    hintText: 'ค้นหารายการขยะทั่วไป',
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
              'รายการขยะทั่วไป',
              style: TextStyle(fontSize: 24),
            ),
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
                                        content: Text(trash['trash_des']),
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
                    }),
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => manageTrash()));
                },
                title: const Text(
                  'แก้ไข',
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
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
                  child: const Icon(Icons.add),
                ),
              ],
            )
          ],
        ),
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
