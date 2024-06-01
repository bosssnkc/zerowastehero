import 'package:flutter/material.dart';

void main() {
  runApp(const CountApp());
}

class CountApp extends StatelessWidget {
  const CountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Count App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const CountPage(),
    );
  }
}

class CountPage extends StatefulWidget {
  const CountPage({super.key});

  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 0;
  void recount() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('CountApp'),
        backgroundColor: Colors.amber[200],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_counter',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.amber),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _counter++;
                  });
                },
                child: const Icon(Icons.plus_one)),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _counter = _counter <= 0 ? 0 : _counter - 1;
                });
              },
              child: const Icon(Icons.remove)),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                recount();
              },
              child: const Icon(Icons.restart_alt_sharp)),
        ],
      )),
    );
  }
}
