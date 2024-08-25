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
            backgroundColor: Colors.green[100],
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
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicatorColor: const Color(0xff1d976c),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
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
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(24),
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
                debugPrint('Clicked');
              },
              child: const SizedBox(
                width: 400,
                height: 300,
                child: Text(
                  'รายละเอียดภายใน',
                  textAlign: TextAlign.center,
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
                debugPrint('card 2 Clicked');
              },
              child: const SizedBox(
                width: 400,
                height: 300,
                child: Text(
                  'รายละเอียดภายใน',
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'หัวข้อ 3',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue,
              onTap: () {
                debugPrint('card 3 Clicked');
              },
              child: const SizedBox(
                  width: 400,
                  height: 300,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'รายละเอียดภายใน',
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
          )
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
            child: gridItem('ขยะทั่วไป', Icons.car_crash, Colors.blue)),
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
            child: gridItem('ขยะอินทรีย์', Icons.five_g_sharp, Colors.green)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const hazadousWaste();
              }));
            },
            child: gridItem('ขยะอันตราย', Icons.biotech, Colors.red)),
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
