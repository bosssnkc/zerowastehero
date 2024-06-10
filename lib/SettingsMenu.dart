import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OptionSetting extends StatefulWidget {
  const OptionSetting({super.key});

  @override
  State<OptionSetting> createState() => _OptionSettingState();
}

class _OptionSettingState extends State<OptionSetting> {
  bool lightswitch = false;

  void lightSwitchCtrl() {
    if (lightswitch == false) {
      return debugPrint('OFF');
    } else {
      return debugPrint('ON');
    }
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
              onTap: () {},
              title: const Text('ตั้งค่า 2'),
              subtitle: const Text('data'),
              leading: const Icon(Icons.safety_check),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('โหมดไฟ'),
              subtitle: const Text('แสบตา?'),
              value: lightswitch,
              onChanged: (value) {
                setState(() {
                  lightswitch = value;
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
