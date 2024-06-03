import 'package:flutter/material.dart';
import 'package:zerowastehero/generalWaste.dart';

class typeOfTrash extends StatefulWidget {
  const typeOfTrash({super.key});

  @override
  State<typeOfTrash> createState() => _typeOfTrashState();
}

class _typeOfTrashState extends State<typeOfTrash> {
  int numpage = 0;
  var name = 'ขยะทั้ง 4 ประเภท';

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
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const SafeArea(
              child: Column(
                children: [
                  TabBar(
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
                      children: <Widget>[
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
    return const Center(
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
    );
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
                child: Text(
                  'รายละเอียดภายใน',
                  textAlign: TextAlign.center,
                ),
              ),
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
                return generalWaste();
              }));
            },
            child: gridItem('ขยะทั่วไป', Icons.car_crash, Colors.blue)),
        gridItem('ขยะรีไซเคิล', Icons.recycling, Colors.amber),
        gridItem('ขยะอินทรีย์', Icons.five_g_sharp, Colors.green),
        gridItem('ขยะอันตราย', Icons.biotech, Colors.red),
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
