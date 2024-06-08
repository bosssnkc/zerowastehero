import 'package:flutter/material.dart';

class recycleWaste extends StatefulWidget {
  const recycleWaste({super.key});

  @override
  State<recycleWaste> createState() => _recycleWasteState();
}

class _recycleWasteState extends State<recycleWaste> {
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
                'ขยะรีไซเคิล',
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
                text: 'รายการขยะรีไซเคิล',
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
            'ขยะรีไซเคิล',
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
    //TODO list
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหารายการขยะ',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search))
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            'รายการขยะรีไซเคิล',
            style: TextStyle(fontSize: 24),
          ),
          // list รายการด้านล่าง
          listGeneralWasteItem('รายการขยะรีไซเคิล 1'),
          listGeneralWasteItem('รายการขยะรีไซเคิล 2'),
          listGeneralWasteItem('รายการขยะรีไซเคิล 3'),
          listGeneralWasteItem('รายการขยะรีไซเคิล 4'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ],
          )
        ],
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
