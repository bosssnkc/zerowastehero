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
                      child: TabBarView(children: <Widget>[
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
                  ]))
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
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                )
              ]),
          child: const Center(
            child: Text(
              'ขยะทั่วไป',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                )
              ]),
          child: const Center(
            child: Text(
              'ขยะรีไซเคิล',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                )
              ]),
          child: const Center(
            child: Text(
              'ขยะอินทรีย์',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                )
              ]),
          child: const Center(
            child: Text('ขยะอันตราย', style: TextStyle(fontSize: 24)),
          ),
        ),
      ],
    );
  }
}
