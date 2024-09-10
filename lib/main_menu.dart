import 'package:flutter/material.dart';
import 'package:zerowastehero/location/hazardous_dump_location.dart';
import 'package:zerowastehero/setting_page.dart';
import 'package:zerowastehero/contact_page.dart';
import 'package:zerowastehero/event_news_page.dart';
import 'package:zerowastehero/profile_page.dart';
import 'package:zerowastehero/trash_type.dart';
import 'package:zerowastehero/location/recycleshop_location.dart';

//หน้าหลัก Main Menu ใช้เพื่อเชื่อมไปยังหน้าต่างอื่นๆ

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // หน้า Home ถูกตั้งค่าไว้ (index = 2)

  static List<Widget> get _widgetOptions => <Widget>[
        const ProfilePage(), //เข้าสู่หน้าจัดการโปรไฟล์ผู้ใช้งาน
        const EventNewsPage(), //เข้าสู่หน้ากิจกรรมและข่าวสาร
        const HomeScreen(), //หน้าหลัก
        const OptionSetting(), //เข้าสู่หน้าตั้งค่า
        const ContactUs(), //เข้าสู่หน้าติดต่อผู้พัฒนาและให้คำแนะนำติชม
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  } //ฟังก์ชันตรวจสอบว่าผู้ใช้เลือกหน้าต่างใดอยู่

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        backgroundColor: Colors.green[300],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zero Waste Hero',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'กิจกรรม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'ติดต่อเรา',
            tooltip: "ให้คำแนะนำเรา",
          ),
        ],
        currentIndex: _selectedIndex,
        // unselectedItemColor: Colors.black,
        // selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToTrashType(BuildContext context, int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TypeOfTrash(selectedTabIndex: tabIndex),
      ), //ฟังก์ชัน Navigate ไปยังหน้าที่ระบุ Tab เฉพาะเจาะจง
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //เมื่อต้องการให้หน้าสามารถเลื่อนขึ้นลงได้
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                InkWell(
                  child: _buildGridItem(Icons.delete, 'ขยะ 4 ประเภท'),
                  onTap: () => _navigateToTrashType(
                      context, 0), //Navigate ไปยัง tab index 0,
                ),
                InkWell(
                  child: _buildGridItem(Icons.help, 'วิธีคัดแยกขยะ'),
                  onTap: () => _navigateToTrashType(
                      context, 1), //Navigate ไปยัง tab index 1,
                ),
                InkWell(
                  child:
                      _buildGridItem(Icons.store, 'สถานที่รับซื้อขยะรีไซเคิล'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecycleLocation(),
                    ),
                  ), // ฟังก์ชันเรียกดูหน้า สถานที่รับซื้อของเก่า
                ),
                InkWell(
                  child: _buildGridItem(
                      Icons.local_hospital, 'สถานที่กำจัดขยะอันตราย'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HazardousLocation(),
                    ),
                  ), //ฟังก์ชันเรียกดูหน้า สถานที่ทิ้งขยะอันตราย
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('กิจกรรม'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {},
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Image(
                      image: NetworkImage(
                          'https://www.baandinthai.com/images/data-baandin/67/67.10/67.10.06/toi09.05.jpg'),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                        right: 0,
                        top: 0,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                            onPressed: () {},
                            child: const Text('รายละเอียดเพิ่มเติม')))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('ข่าวสาร'),
            const SizedBox(height: 8),
            Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: const Image(
                  image: NetworkImage(
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }
}
