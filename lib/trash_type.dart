import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/trashs/compostable_waste_page.dart';
import 'package:zerowastehero/trashs/general_waste_page.dart';
import 'package:zerowastehero/trashs/hazadous_waste_page.dart';
import 'package:zerowastehero/trashs/recycle_waste_page.dart';
import 'package:zerowastehero/search_page.dart';

class TypeOfTrash extends StatefulWidget {
  final int selectedTabIndex;
  const TypeOfTrash({super.key, this.selectedTabIndex = 0});

  @override
  State<TypeOfTrash> createState() => _TypeOfTrashState();
}

class _TypeOfTrashState extends State<TypeOfTrash>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String name;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedTabIndex);
    _tabController.addListener(_handleTabSelection);
    name = _getTabName(_tabController.index);
  }

  void _handleTabSelection() {
    setState(() {
      name = _getTabName(_tabController.index);
    });
  }

  String _getTabName(int index) {
    if (index == 0) {
      return 'ขยะทั้ง 4 ประเภท';
    } else {
      return 'วิธีคัดแยกขยะ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.selectedTabIndex,
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
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    child: Text(
                      'ขยะทั้ง 4 ประเภท',
                    ),
                  ),
                  Tab(
                    child: Text(
                      'วิธีคัดแยกขยะ',
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const <Widget>[
                        FourTypeOfTrash(),
                        howToSortingPage(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}

class FourTypeOfTrash extends StatefulWidget {
  const FourTypeOfTrash({super.key});

  @override
  State<FourTypeOfTrash> createState() => _FourTypeOfTrashState();
}

class _FourTypeOfTrashState extends State<FourTypeOfTrash> {
  final searchController = TextEditingController();
  bool isTextEmpty = true;

  void searchClear() {
    searchController.clear();
  }

  Future<void> _searchTrash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashsearch = searchController.text;
    if (trashsearch.isEmpty) {
      setState(() {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()));
      });
    } else {
      setState(() {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()));
      });
      await prefs.setString('trashname', trashsearch);
      searchController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        isTextEmpty = searchController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: 'ค้นหารายการขยะ',
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ))),
                  IconButton(
                    tooltip:
                        isTextEmpty ? 'แสดงรายการทั้งหมด' : 'ค้นหารายการขยะ',
                    onPressed: () {
                      _searchTrash();
                    },
                    icon: isTextEmpty
                        ? const Icon(Icons.list)
                        : const Icon(Icons.search),
                  )
                ],
              )),
          const SizedBox(
            height: 24,
          ),
          const Text(
            'ขยะในประเภทต่างๆ',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: gridWieget(),
          )
        ],
      ),
    ));
  }
}

class howToSortingPage extends StatelessWidget {
  const howToSortingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'วิธีคัดแยกขยะ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ปิด'))
                              ],
                              insetPadding: const EdgeInsets.all(16),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              title: const Text('วิธีคัดแยกขยะ'),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: const SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '    การแยกขยะเบื้องต้นเป็นวิธีการสำคัญในการจัดการขยะอย่างถูกต้องและลดผลกระทบต่อสิ่งแวดล้อม โดยวิธีการคัดแยกขยะในเบื้องต้นมีวิธีดังนี้',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'แยกขยะตามประเภทหลัก',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '    ขยะทั่วไป: เช่น ถุงพลาสติก หลอด ขวดน้ำแบบใช้ครั้งเดียว',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '    ขยะรีไซเคิล: เช่น ขวดพลาสติก กระป๋องโลหะ กระดาษ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '    ขยะอินทรีย์: เช่น เศษอาหาร เปลือกผลไม้ ใบไม้',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '    ขยะอันตราย: เช่น แบตเตอรี่ หลอดไฟ ถ่านไฟฉาย',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'ใช้ถังขยะแยกตามประเภท',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '    จัดเตรียมถังขยะแต่ละประเภทให้ชัดเจนด้วยสี หรือสัญลักษณ์ที่เหมาะสม',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'ทำความสะอาดขยะรีไซเคิลก่อนทิ้ง',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '    ล้างหรือทำความสะอาดบรรจุภัณฑ์และวัสดุต่าง ๆ ก่อนทิ้งลงถังรีไซเคิลเพราะอาจจะปนเปื้อนจนไม่สามารถนำไปเข้าสู่กระบวนการรีไซเคิลได้',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'ทิ้งขยะอันตรายในจุดรับขยะเฉพาะ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '    ขยะอันตรายต้องแยกและทิ้งในสถานที่ที่กำหนดเพื่อความปลอดภัย',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )));
              },
              child: const SizedBox(
                width: 400,
                height: 300,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment(1, 1),
                    children: [
                      Text(
                        'คลิกเพื่ออ่านต่อ...',
                        style:
                            TextStyle(color: Color.fromARGB(255, 39, 73, 133)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '    การแยกขยะเบื้องต้นเป็นวิธีการสำคัญในการจัดการขยะอย่างถูกต้องและลดผลกระทบต่อสิ่งแวดล้อม โดยวิธีการคัดแยกขยะในเบื้องต้นมีวิธีดังนี้',
                          ),
                          Text(
                            'แยกขยะตามประเภทหลัก',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              '    ขยะทั่วไป: เช่น ถุงพลาสติก หลอด ขวดน้ำแบบใช้ครั้งเดียว'),
                          Text(
                              '    ขยะรีไซเคิล: เช่น ขวดพลาสติก กระป๋องโลหะ กระดาษ'),
                          Text(
                              '    ขยะอินทรีย์: เช่น เศษอาหาร เปลือกผลไม้ ใบไม้'),
                          Text(
                              '    ขยะอันตราย: เช่น แบตเตอรี่ หลอดไฟ ถ่านไฟฉาย'),
                          Text('ใช้ถังขยะแยกตามประเภท',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '    จัดเตรียมถังขยะแต่ละประเภทให้ชัดเจนด้วยสีหรือสัญลักษณ์ที่เหมาะสม'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'วิธีการลดขยะ ด้วยหลักการ 3R',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ปิด'))
                              ],
                              insetPadding: const EdgeInsets.all(16),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              title: const Text('วิธีการลดขยะด้วยหลักการ 3R'),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: const SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '    หลักการ 3R หรือลดใช้ ใช้ซ้ำ นำกลับมาใช้ใหม่ เป็นแนวทางในการลดขยะและใช้ทรัพยากรอย่างมีประสิทธิภาพ การปฏิบัติตามหลักการ 3R ช่วยลดปริมาณขยะ ลดการใช้ทรัพยากรธรรมชาติ และสนับสนุนการรักษาสิ่งแวดล้อมในระยะยาว',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'โดยหลักการ 3R ประกอบไปด้วย',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '    1. Reduce (ลดการใช้) ลดการใช้วัสดุและทรัพยากรที่ไม่จำเป็น เลือกซื้อเฉพาะสิ่งที่จำเป็นและลดการซื้อสินค้าที่ใช้ครั้งเดียว เช่น หลีกเลี่ยงการใช้ถุงพลาสติก และเลือกใช้ถุงผ้าแทน',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                          '    2. Recycle (ใช้ซ้ำ) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว แยกขยะรีไซเคิลอย่างถูกต้อง แยกขยะที่สามารถรีไซเคิลได้ เช่น กระดาษ แก้ว พลาสติก และโลหะ ออกจากขยะอื่น ๆ และนำไปทิ้งในจุดรับขยะรีไซเคิล',
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                          '    3. Recycle (นำกลับมาใช้ใหม่) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว ซ่อมแซมสินค้าแทนการทิ้ง หากสินค้าที่เสียหรือชำรุดสามารถซ่อมแซมได้ ให้ซ่อมและใช้งานต่อไปแทนการทิ้งและซื้อใหม่',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            )));
              },
              child: const SizedBox(
                width: 400,
                height: 300,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment(1, 1),
                    children: [
                      Text(
                        'คลิกเพื่ออ่านต่อ...',
                        style:
                            TextStyle(color: Color.fromARGB(255, 39, 73, 133)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '    หลักการ 3R หรือลดใช้ ใช้ซ้ำ นำกลับมาใช้ใหม่ เป็นแนวทางในการลดขยะและใช้ทรัพยากรอย่างมีประสิทธิภาพ การปฏิบัติตามหลักการ 3R ช่วยลดปริมาณขยะ ลดการใช้ทรัพยากรธรรมชาติ และสนับสนุนการรักษาสิ่งแวดล้อมในระยะยาว',
                          ),
                          Text(
                            'โดยหลักการ 3R ประกอบไปด้วย',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              '    1. Reduce (ลดการใช้) ลดการใช้วัสดุและทรัพยากรที่ไม่จำเป็น เลือกซื้อเฉพาะสิ่งที่จำเป็นและลดการซื้อสินค้าที่ใช้ครั้งเดียว เช่น หลีกเลี่ยงการใช้ถุงพลาสติก และเลือกใช้ถุงผ้าแทน'),
                          Text(
                              '    2. Recycle (ใช้ซ้ำ) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class gridWieget extends StatelessWidget {
  const gridWieget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const generalWaste();
              }));
            },
            child: gridItem('ขยะทั่วไป', Icons.delete, Colors.blue)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const recycleWaste();
              }));
            },
            child: gridItem('ขยะรีไซเคิล', Icons.recycling, Colors.amber)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const compostableWaste();
              }));
            },
            child: gridItem('ขยะอินทรีย์', Icons.eco, Colors.green)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const hazadousWaste();
              }));
            },
            child: gridItem('ขยะอันตราย', Icons.masks_rounded, Colors.red)),
      ],
    );
  }

  Widget gridItem(String jname, IconData icon, Color iconCol) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              jname,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Icon(
            icon,
            size: 60,
            color: iconCol,
          )
        ],
      ),
    );
  }
}
