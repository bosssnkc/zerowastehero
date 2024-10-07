import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventNewsPage extends StatefulWidget {
  const EventNewsPage({super.key});

  @override
  State<EventNewsPage> createState() => _EventNewsPageState();
}

class _EventNewsPageState extends State<EventNewsPage> {
  final List<Map<String, String>> activities = [
    {
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202409/jobs-header-9cc6b7e1bcca9ec857d7e662533c5d7f.jpg',
      'url': 'https://www.jitarsabank.com/job/detail/10134'
    },
    {
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202410/jobs-header-c9977a60d23b6854c28c5f9fb49c9ca1.jpeg',
      'url': 'https://www.jitarsabank.com/job/detail/10206'
    },
    {
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202410/jobs-header-78d1bb401319690e6fe695a527794de7.jpeg',
      'url': 'https://www.jitarsabank.com/job/detail/10207'
    },
  ];

  final List<Map<String, String>> news = [
    {
      'title': 'กทม. ชวนผู้ประกอบการร้านอาหารที่ ‘สมัครใจแยกขยะ’',
      'image':
          'https://scontent.fbkk22-1.fna.fbcdn.net/v/t39.30808-6/461928643_867909578850526_6266896552636537459_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEEvqE2Ing8gtDGOcyelANGa0Mh9123reZrQyH3Xbet5n8BxkspI_dWwvqZLT47HxfhV0fxRtVJpC8vGq-tenZF&_nc_ohc=rkGPGFRFOLUQ7kNvgEt7XBR&_nc_ht=scontent.fbkk22-1.fna&_nc_gid=AjCNHySP55mn0JFT48MQVxD&oh=00_AYCi2fvRobm2u6vr9rWip_Z0NDLtAwitUtoxfnmKfRcGZA&oe=670A0FEC',
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'กิจกรรม',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 220,
                    child: PageView.builder(
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final event = activities[index];
                          return Stack(
                            children: [
                              Image(
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
                                    child: const Text('รายละเอียดเพิ่มเติม')),
                              )
                            ],
                          );
                        }),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'ข่าวสาร',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
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
                                    Image(
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                      image: NetworkImage('${newss['image']}'),
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
                                          child: const Text(
                                              'รายละเอียดเพิ่มเติม')),
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
            ],
          ),
        ),
      ),
    );
  }
}
