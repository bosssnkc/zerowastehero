import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ติดต่อผู้พัฒนา',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Card(
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
              const SizedBox(
                height: 16,
              ),
              const Text(
                'ข้อเสนอแนะ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            final Uri urllink = Uri.parse(
                                'https://docs.google.com/forms/d/e/1FAIpQLSfNi8DbQOVmhQsceyH6LtvSODuW7BW8Qg7daEuOUlsINua14A/viewform');
                            if (await canLaunchUrl(urllink)) {
                              await launchUrl(urllink);
                            }
                          },
                          child: const Text(
                            'แบบประเมินความพึงพอใจ และเขียนข้อเสนอแนะ',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )),
                      const Text('หรือ'),
                      TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            final Uri urllink = Uri.parse(
                                'https://docs.google.com/forms/d/e/1FAIpQLSd-oZa26nvR-7zQILlX1WTxzTOtj8t3gd5eXhsN_fpcQMqffg/viewform');
                            if (await canLaunchUrl(urllink)) {
                              await launchUrl(urllink);
                            }
                          },
                          child: const Text(
                            'เขียนข้อเสนอแนะและคำแนะนำ',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 240,
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Yaek and Ting version 1.1.0',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
