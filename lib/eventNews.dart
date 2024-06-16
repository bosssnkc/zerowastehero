import 'package:flutter/material.dart';

class eventNewsPage extends StatefulWidget {
  const eventNewsPage({super.key});

  @override
  State<eventNewsPage> createState() => _eventNewsPageState();
}

class _eventNewsPageState extends State<eventNewsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ข่าวสาร',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 200,
              child: Card(
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.red[50],
                  child: const Center(
                    child: Text('ภาพ'),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'กิจกรรม',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 200,
              child: Card(
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.cyan[50],
                  child: const Center(
                    child: Text('ภาพ2'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
