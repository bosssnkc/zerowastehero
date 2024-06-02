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
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              _settingContainer(Icons.help, 'TEST'),
              _settingContainer(Icons.notification_add, 'TEST2'),
              _settingContainer(Icons.book, 'TEST3'),
              _settingContainer(Icons.set_meal, 'TEST4')
            ],
          ),
          const SizedBox(height: 16),
          const ListTile(
            title: Text('ตั้งค่า 1'),
            subtitle: Text('ListTile Widget/title Test'),
            leading: Icon(Icons.safety_check),
            trailing: Icon(Icons.fire_extinguisher),
          ),
          const ListTile(
            title: Text('ตั้งค่า 2'),
            leading: Icon(Icons.safety_check),
            trailing: Icon(Icons.fire_extinguisher),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: Colors.white,
                )),
            child: Container(
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
            )),
          )
        ],
      ),
    ));
  }

  Widget _settingContainer(
    IconData icon,
    String label,
  ) {
    return SizedBox(
      height: 5.0,
      width: 5.0,
      child: Row(
        children: [
          Icon(icon),
          Text(label),
        ],
      ),
    );
  }
}
