import 'package:flutter/material.dart';

class EventNewsPage extends StatefulWidget {
  const EventNewsPage({super.key});

  @override
  State<EventNewsPage> createState() => _EventNewsPageState();
}

class _EventNewsPageState extends State<EventNewsPage> {
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
              'กิจกรรม',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Image(
                    image: NetworkImage(
                        'https://www.baandinthai.com/images/data-baandin/67/67.10/67.10.06/toi09.05.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
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
