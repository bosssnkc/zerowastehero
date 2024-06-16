import 'package:flutter/material.dart';

class recycleLocation extends StatefulWidget {
  const recycleLocation({super.key});

  @override
  State<recycleLocation> createState() => _recycleLocationState();
}

class _recycleLocationState extends State<recycleLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[300],
        title: const Text(
          'สถานที่รับซื้อขยะรีไซเคิล',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 50,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตำแหน่งปัจจุบันของคุณ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text('{location now}')
                        ],
                      ), //Column inside location_now
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'แผนที่',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Text('{location_recycleshop}'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class hazardousLocation extends StatefulWidget {
  const hazardousLocation({super.key});

  @override
  State<hazardousLocation> createState() => _hazardousLocationState();
}

class _hazardousLocationState extends State<hazardousLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[300],
        title: const Text(
          'สถานที่กำจัดขยะอันตราย',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 50,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตำแหน่งปัจจุบันของคุณ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text('{location now}')
                        ],
                      ), //Column inside location_now
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'แผนที่',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Text('{location_hazardousDump}'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
