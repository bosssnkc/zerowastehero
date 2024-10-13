import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerowastehero/Routes/routes.dart';
import 'package:zerowastehero/location/hazardous_dump_location.dart';
import 'package:zerowastehero/session.dart';
import 'package:zerowastehero/setting_page.dart';
import 'package:zerowastehero/contact_page.dart';
import 'package:zerowastehero/event_news_page.dart';
import 'package:zerowastehero/profile_page.dart';
import 'package:zerowastehero/trash_type.dart';
import 'package:zerowastehero/location/recycleshop_location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

//หน้าหลัก Main Menu ใช้เพื่อเชื่อมไปยังหน้าต่างอื่นๆ

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // หน้า Home ถูกตั้งค่าไว้ (index = 2)

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'Unknown User';
    String? token = prefs.getString('jwt_token');
    String? guestToken = prefs.getString('guestToken') ?? null;
    // print(token);

    if (guestToken != null) {
      return {'firstname': 'Guest', 'lastname': 'User', 'email': 'anonymous'};
    }

    // If no token found, redirect to login page
    if (token == null) {
      _redirectToLogin(prefs, context, 'พบการเข้าถึงที่ไม่ถูกต้อง',
          'การเข้าถึงไม่ถูกต้อง กรุณาทำการเข้าสู่ระบบใหม่');
      return {};
    }

    // Check if token is expired
    bool isExpired = JwtDecoder.isExpired(token);
    if (isExpired) {
      // Token is expired, clear preferences and redirect to login
      _redirectToLogin(prefs, context, 'Session หมดอายุ',
          'Session หมดอายุ กรุณาทำการเข้าสู่ระบบใหม่');
      return {};
    }

    // Token is valid, make the API call to fetch user data
    final response = await http.get(
      Uri.parse('$getuserinfo$username'),
      headers: {
        'Authorization': 'Bearer $token'
      }, // Add 'Bearer' to Authorization header
    );

    if (response.statusCode == 200) {
      // Successfully fetched user info
      return jsonDecode(response.body);
    } else {
      // Handle failed API response
      print('Failed to load user info: ${response.statusCode}');
      throw Exception('Failed to load user data');
    }
  }

// Helper function to handle redirection to login
  void _redirectToLogin(SharedPreferences prefs, BuildContext context,
      String title, String message) {
    prefs.remove('guestToken');
    prefs.setBool('isLoggedIn', false);
    prefs.remove('username');
    prefs.remove('user_id');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

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
          'Yaek and Ting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/zwh_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
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
  final List<Map<String, String>> activities = [
    {
      'title': 'กิจกรรมเก็บขยะ ปล่อยหอย ปล่อยปู หาดตะวันรอน จ.ชลบุรี รอบ 16',
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202409/jobs-header-9cc6b7e1bcca9ec857d7e662533c5d7f.jpg',
      'url': 'https://www.jitarsabank.com/job/detail/10134'
    },
    {
      'title': 'กิจกรรมพายเรือเก็บขยะ อนุรักษ์คลองบางกอบัว คุ้งบางกระเจ้า รุ่น 25',
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202410/jobs-header-c9977a60d23b6854c28c5f9fb49c9ca1.jpeg',
      'url': 'https://www.jitarsabank.com/job/detail/10206'
    },
    {
      'title':
          'รุ่น 10 ปี 67 วันอาทิตย์ 17 พฤศจิกายน 2567 อาสาพิทักษ์ชายฝั่งทะเล ( ทำความสะอาดบ้านเต่าทะเล + ทำความสะอาดชายหาด ) อ.สัตหีบ จ.ชลบุรี',
      'image':
          'https://www.baandinthai.com/images/data-baandin/67/67.11/67.11.17/toi10.05.jpg',
      'url':
          'https://www.volunteerspirit.org/รุ่น-10-ปี-67-วันอาทิตย์-17-พฤศจ/48754/'
    },
  ];

  final List<Map<String, String>> news = [
    {
      'title': 'กทม. ชวนผู้ประกอบการร้านอาหารที่ ‘สมัครใจแยกขยะ’',
      'image':
          'assets/image/mai.jpg',
      'url':
          'https://www.facebook.com/photo/?fbid=867909575517193&set=a.249425947365562'
    },
    {
      'title': 'ล้างบางปัญหาลอบทิ้งขยะพิษ',
      'image':
          'https://static.thairath.co.th/media/dFQROr7oWzulq5Fa6rBj3pZaODqlZ8tEox1FUhQX12JKr0I1MLDRRFHd5WDnaruXdNW.webp',
      'url': 'https://www.thairath.co.th/news/local/2818486'
    },
    // {
    //   'title': '',
    //   'image': '',
    //   'url': ''
    // },
  ];

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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  child: PageView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final event = activities[index];
                        return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'หัวเรื่อง: ${event['title']}',maxLines: 2,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 16,
                                      backgroundColor: Colors.white),
                                ),
                                Stack(
                                  children: [
                                    Image(
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                      image: NetworkImage('${event['image']}'),
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            final Uri urllink =
                                                Uri.parse(event['url'] ?? '');
                                            if (await canLaunchUrl(urllink)) {
                                              await launchUrl(urllink);
                                            }
                                          },
                                          child:
                                              const Text('รายละเอียดเพิ่มเติม')),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                      }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('ข่าวสาร'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  child: PageView.builder(
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final newss = news[index];
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'หัวเรื่อง: ${newss['title']}',
                                style: TextStyle(
                                    fontSize: 16,
                                    backgroundColor: Colors.white),
                              ),
                              Stack(
                                children: [
                                  newss['image']!.startsWith('http') ?
                                  Image(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    image: NetworkImage('${newss['image']}'),
                                    fit: BoxFit.cover,
                                  ) : Image(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    image: AssetImage('${newss['image']}'),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          final Uri urllink =
                                              Uri.parse(newss['url'] ?? '');
                                          if (await canLaunchUrl(urllink)) {
                                            await launchUrl(urllink);
                                          }
                                        },
                                        child:
                                            const Text('รายละเอียดเพิ่มเติม')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
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
