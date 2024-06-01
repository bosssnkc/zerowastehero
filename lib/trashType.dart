import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class typeOfTrash extends StatefulWidget {
  const typeOfTrash({super.key});

  @override
  State<typeOfTrash> createState() => _typeOfTrashState();
}

class _typeOfTrashState extends State<typeOfTrash> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.green[200],
            appBar: AppBar(
              backgroundColor: Colors.green[300],
              elevation: 0,
              title: const Text(
                'ขยะ 4 ประเภท',
                style: TextStyle(
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
                        text: "ขยะทั้ง 4 ประเภท",
                      ),
                      Tab(
                        text: "วิธีคัดแยกขยะ",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                        ),
                        Center(
                          child: Text('TEST'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )));
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
            onTap: () {},
            child: gridItem('ขยะทั่วไป', Icons.recycling, Colors.blue)),
        gridItem('ขยะรีไซเคิล', Icons.text_snippet, Colors.amber),
        gridItem('ขยะอินทรีย์', Icons.five_g_sharp, Colors.green),
        gridItem('ขยะอันตราย', Icons.biotech, Colors.red),
      ],
    );
  }

  Widget gridItem(String jname, IconData icon, Color iconCol) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
            )
          ]),
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
