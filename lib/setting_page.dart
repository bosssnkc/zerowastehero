import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/main.dart';
import 'package:zerowastehero/manual.dart';

class OptionSetting extends StatefulWidget {
  const OptionSetting({Key? key}) : super(key: key);

  @override
  State<OptionSetting> createState() => _OptionSettingState();
}

class _OptionSettingState extends State<OptionSetting> {
  bool lightswitch = false;
  String selectedFont = 'Kanit';

  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFont = prefs.getString('selectedFont') ?? 'Kanit';
    });
  }

  Future<void> _setFont(String font) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFont', font);
    setState(() {
      selectedFont = font;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนฟอนต์สำเร็จ'),
        content: Text(
            'เปลี่ยนฟอนต์ เป็น $selectedFont สำเร็จ กรุณาทำการรีสตาร์ทแอปพลิเคชันใหม่เพื่อทำการโหลดฟอนต์'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyApp()));
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red),
            icon: Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
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
              child: ExpansionTile(
                shape: const Border(),
                leading: Icon(Icons.font_download),
                title: const Text('ตั้งค่า Font'),
                subtitle: Text('ฟอนต์ปัจจุบัน $selectedFont'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 24, 4),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedFont,
                      items: [
                        DropdownMenuItem(
                          value: 'Pridi',
                          child: Text(
                            'Pridi',
                            style: GoogleFonts.pridi(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Kanit',
                          child: Text(
                            'Kanit',
                            style: GoogleFonts.kanit(),
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _setFont(newValue);
                          // เรียกฟังก์ชันเพื่อเปลี่ยนฟอนต์
                        }
                      },
                      underline: Container(), // ปิดเส้นใต้ของ Dropdown
                      hint: Text('เลือกฟอนต์'), // ข้อความเมื่อไม่มีการเลือก
                    ),
                  ),
                ],
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
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ManualPage()));
                },
                title: const Text('วิธีการใช้งาน'),
                subtitle: const Text('คู่มือแนะนำการใช้งาน'),
                leading: const Icon(Icons.help),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
