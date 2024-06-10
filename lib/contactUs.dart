import 'package:flutter/material.dart';

class contactUs extends StatefulWidget {
  const contactUs({super.key});

  @override
  State<contactUs> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<contactUs> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ติดต่อผู้พัฒนา',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 50,
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'นายวิทยา สุขช่วย',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email:'),
                                Text('Tel:'),
                                Text('Line:'),
                              ],
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('wittaya.suk64@chandra.ac.th'),
                                Text('080-446-3368'),
                                Text('rabbitsorrow.tao'),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'ข้อเสนอแนะ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'เขียนคำติชมหรือให้คำแนะนำเรา',
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {}, child: const Text('Confirm')),
                        SizedBox(
                          width: 20,
                        ),
                        TextButton(
                            onPressed: () {}, child: const Text('Cancel')),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}