import 'package:flutter/material.dart';

class generalWaste extends StatefulWidget {
  const generalWaste({super.key});

  @override
  State<generalWaste> createState() => _genralWasteState();
}

class _genralWasteState extends State<generalWaste> {
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
    return Padding(
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
    );
  }

  Widget listOfGeneral() {
    //TODO list
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'TEST',
              hintText: 'test',
              border: OutlineInputBorder(),
            ),
          )
        ],
      ),
    );
  }
}
