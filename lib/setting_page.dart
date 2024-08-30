import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionSetting extends StatefulWidget {
  const OptionSetting({super.key});

  @override
  State<OptionSetting> createState() => _OptionSettingState();
}

class _OptionSettingState extends State<OptionSetting> {
  bool lightswitch = false;

  Future<void> _getValueSwitch(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('lightswitch', value);
    print(prefs.getBool('lightswitch'));
    setState(() {
      lightswitch = prefs.getBool('lightswitch')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text(
            'การตั้งค่า',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              onTap: () {},
              title: const Text('ตั้งค่าภาษา'),
              subtitle: const Text('ตั้งค่าภาษาใช้งาน'),
              leading: const Icon(Icons.language),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      title: const Text('เลือกตัวอักษร / Fonts'),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              onTap: () {},
                              title: const Text('Pridi'),
                              subtitle: Text(
                                'ทดสอบข้อความ',
                                style: GoogleFonts.pridi(),
                              ),
                            ),
                            ListTile(
                              onTap: () {},
                              title: const Text('Kanit'),
                              subtitle: Text(
                                'ทดสอบข้อความ',
                                style: GoogleFonts.kanit(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('ตกลง'))
                      ],
                    ),
                  ),
                );
              },
              title: const Text('ตั้งค่าตัวอักษร'),
              subtitle: const Text('data'),
              leading: const Icon(Icons.font_download),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('โหมดไฟ'),
              subtitle: const Text('แสบตา?'),
              value: lightswitch,
              onChanged: (bool value) {
                setState(() {
                  lightswitch = value;
                  _getValueSwitch(value);
                });
              },
              secondary: const Icon(Icons.light_mode),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ช่วยเหลือ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              onTap: () {},
              title: const Text('วิธีการใช้งาน'),
              subtitle: const Text('คู่มือแนะนำการใช้งาน'),
              leading: const Icon(Icons.help),
            ),
          ),
        ],
      ),
    ));
  }
}
