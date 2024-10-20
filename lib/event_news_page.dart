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
      'title': 'กิจกรรมเก็บขยะ ปล่อยหอย ปล่อยปู หาดตะวันรอน จ.ชลบุรี รอบ 16',
      'image':
          'https://upload-storage.jitarsabank.com/jbank-storage/202409/jobs-header-9cc6b7e1bcca9ec857d7e662533c5d7f.jpg',
      'url': 'https://www.jitarsabank.com/job/detail/10134'
    },
    {
      'title':
          'กิจกรรมพายเรือเก็บขยะ อนุรักษ์คลองบางกอบัว คุ้งบางกระเจ้า รุ่น 25',
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
      'image': 'assets/image/mai.jpg',
      'url':
          'https://www.facebook.com/photo/?fbid=867909575517193&set=a.249425947365562'
    },
    {
      'title': 'ล้างบางปัญหาลอบทิ้งขยะพิษ',
      'image':
          'https://static.thairath.co.th/media/dFQROr7oWzulq5Fa6rBj3pZaODqlZ8tEox1FUhQX12JKr0I1MLDRRFHd5WDnaruXdNW.webp',
      'url': 'https://www.thairath.co.th/news/local/2818486'
    },
    {
      'title': 'โครงการ “Green University ทิ้ง เทิร์น ให้โลกจำ upvel2”',
      'image': 'assets/image/event1.jpg',
      'url': 'https://www.facebook.com/NatureAndEnvironmentConservationClub/posts/979532804216515'
    },
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
                                  'หัวเรื่อง: ${event['title']}',
                                  maxLines: 2,
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
                                          child: const Text(
                                              'รายละเอียดเพิ่มเติม')),
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
                                  maxLines: 2,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 16,
                                      backgroundColor: Colors.white),
                                ),
                                Stack(
                                  children: [
                                    newss['image']!.startsWith('http')
                                        ? Image(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 200,
                                            image: NetworkImage(
                                                '${newss['image']}'),
                                            fit: BoxFit.cover,
                                          )
                                        : Image(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 200,
                                            image:
                                                AssetImage('${newss['image']}'),
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
