import 'package:flutter/material.dart';
import 'package:zerowastehero/compostableWaste.dart';
import 'package:zerowastehero/generalWaste.dart';
import 'package:zerowastehero/hazadousWaste.dart';
import 'package:zerowastehero/recycleWaste.dart';

class typeOfTrash extends StatefulWidget {
  final int selectedTabIndex;
  const typeOfTrash({super.key, this.selectedTabIndex = 0});

  @override
  State<typeOfTrash> createState() => _typeOfTrashState();
}

class _typeOfTrashState extends State<typeOfTrash>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String name;
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
  // var name = 'ขยะทั้ง 4 ประเภท';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.selectedTabIndex,
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.green[100],
            appBar: AppBar(
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
            ),
            body: SafeArea(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: 'ขยะทั้ง 4 ประเภท',
                      ),
                      Tab(
                        text: 'วิธีคัดแยกขยะ',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const <Widget>[
                        fourTypeOfTrash(),
                        howToSortingPage(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}

class fourTypeOfTrash extends StatelessWidget {
  const fourTypeOfTrash({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            'ขยะในประเภทต่างๆ',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(
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
