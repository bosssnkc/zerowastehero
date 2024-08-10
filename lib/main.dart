import 'package:flutter/material.dart';
import 'package:zerowastehero/session.dart';
// import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Zero Waste Hero',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: SplashScreen());
    // home: Scaffold(
    //   appBar: AppBar(
    //     title: Text('TEST CONNNECTION'),
    //   ),
    //   body: Center(
    //     child: ElevatedButton(
    //       onPressed: () async {
    //         final respone = await http
    //             .get(Uri.parse('http://zerowasteheroapp.com/api/data'));
    //         print('Respond from NODE.js ${respone.body}');
    //       },
    //       child: Text('test connect'),
    //     ),
    //   ),
    // ));
  }
}
