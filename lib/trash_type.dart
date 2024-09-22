import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zerowastehero/trashs/compostable_waste_page.dart';
import 'package:zerowastehero/trashs/general_waste_page.dart';
import 'package:zerowastehero/trashs/hazadous_waste_page.dart';
import 'package:zerowastehero/trashs/recycle_waste_page.dart';
import 'package:zerowastehero/search_page.dart';
import 'custom_icons_icons.dart';

class TypeOfTrash extends StatefulWidget {
  final int selectedTabIndex;
  const TypeOfTrash({super.key, this.selectedTabIndex = 0});

  @override
  State<TypeOfTrash> createState() => _TypeOfTrashState();
}

class _TypeOfTrashState extends State<TypeOfTrash>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String name;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedTabIndex);
    _tabController.addListener(_handleTabSelection);
    name = _getTabName(_tabController.index);
  }

  void _handleTabSelection() {
    setState(() {
      name = _getTabName(_tabController.index);
    });
  }

  String _getTabName(int index) {
    if (index == 0) {
      return 'ขยะทั้ง 4 ประเภท';
    } else {
      return 'วิธีคัดแยกขยะ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.selectedTabIndex,
        length: 2,
        child: Scaffold(
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
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    child: Text(
                      'ขยะทั้ง 4 ประเภท',
                    ),
                  ),
                  Tab(
                    child: Text(
                      'วิธีคัดแยกขยะ',
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const <Widget>[
                        FourTypeOfTrash(),
                        HowToSortingPage(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}

class FourTypeOfTrash extends StatefulWidget {
  const FourTypeOfTrash({super.key});

  @override
  State<FourTypeOfTrash> createState() => _FourTypeOfTrashState();
}

class _FourTypeOfTrashState extends State<FourTypeOfTrash> {
  final searchController = TextEditingController();
  bool isTextEmpty = true;

  void searchClear() {
    searchController.clear();
  }

  Future<void> _searchTrash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trashsearch = searchController.text;
    if (trashsearch.isEmpty) {
      setState(() {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()));
      });
    } else {
      setState(() {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()));
      });
      await prefs.setString('trashname', trashsearch);
      searchController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        isTextEmpty = searchController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: 'ค้นหารายการขยะ',
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ))),
                  IconButton(
                    tooltip:
                        isTextEmpty ? 'แสดงรายการทั้งหมด' : 'ค้นหารายการขยะ',
                    onPressed: () {
                      _searchTrash();
                    },
                    icon: isTextEmpty
                        ? const Icon(Icons.list)
                        : const Icon(Icons.search),
                  )
                ],
              )),
          const SizedBox(
            height: 24,
          ),
          const Text(
            'ขยะในประเภทต่างๆ',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: GridWieget(),
          )
        ],
      ),
    ));
  }
}

class HowToSortingPage extends StatefulWidget {
  const HowToSortingPage({super.key});

  @override
  State<HowToSortingPage> createState() => _HowToSortingPageState();
}

class _HowToSortingPageState extends State<HowToSortingPage> {
  final List<String> _VideoIds = [
    'qxUWkr1_JQw', // index 0
    'nBuLxKc7FDI', // index 1
  ];

  String _VideoId = '';

  late YoutubePlayerController _playerController;

  Future<void> setYouTubeController() async {
    _playerController = YoutubePlayerController(
      initialVideoId: _VideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        loop: false,
        disableDragSeek: false,
        isLive: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'วิธีคัดแยกขยะ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                setState(() {
                  _VideoId = _VideoIds[0];
                  print(_VideoId);
                  setYouTubeController();
                });
                // initState();
                showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      actions: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('ปิด'))
                      ],
                      insetPadding: const EdgeInsets.all(16),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      title: const Text('วิธีคัดแยกขยะ'),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text:
                                          '    การแยกขยะเบื้องต้นเป็นวิธีการสำคัญในการจัดการขยะอย่างถูกต้องและลดผลกระทบต่อสิ่งแวดล้อม โดยวิธีการคัดแยกขยะในเบื้องต้นมีวิธีดังนี้\n',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'แยกขยะตามประเภทหลัก\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '    ขยะทั่วไป: เช่น ถุงพลาสติก หลอด ขวดน้ำแบบใช้ครั้งเดียว\n',
                                    ),
                                    TextSpan(
                                      text:
                                          '    ขยะรีไซเคิล: เช่น ขวดพลาสติก กระป๋องโลหะ กระดาษ\n',
                                    ),
                                    TextSpan(
                                      text:
                                          '    ขยะอินทรีย์: เช่น เศษอาหาร เปลือกผลไม้ ใบไม้\n',
                                    ),
                                    TextSpan(
                                      text:
                                          '    ขยะอันตราย: เช่น แบตเตอรี่ หลอดไฟ ถ่านไฟฉาย\n',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'ใช้ถังขยะแยกตามประเภท\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '    จัดเตรียมถังขยะแต่ละประเภทให้ชัดเจนด้วยสี หรือสัญลักษณ์ที่เหมาะสม\n',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'ทำความสะอาดขยะรีไซเคิลก่อนทิ้ง\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '    ล้างหรือทำความสะอาดบรรจุภัณฑ์และวัสดุต่าง ๆ ก่อนทิ้งลงถังรีไซเคิลเพราะอาจจะปนเปื้อนจนไม่สามารถนำไปเข้าสู่กระบวนการรีไซเคิลได้\n',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: 'ทิ้งขยะอันตรายในจุดรับขยะเฉพาะ\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '    ขยะอันตรายต้องแยกและทิ้งในสถานที่ที่กำหนดเพื่อความปลอดภัย\n',
                                    ),
                                  ],
                                ),
                              ),

                              // Video
                              YoutubePlayer(
                                controller: _playerController,
                                showVideoProgressIndicator: true,
                                onReady: () {
                                  print('Player is ready.');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 400,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          'คลิกเพื่ออ่านต่อ...',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 73, 133)),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(
                                    text:
                                        '    การแยกขยะเบื้องต้นเป็นวิธีการสำคัญในการจัดการขยะอย่างถูกต้องและลดผลกระทบต่อสิ่งแวดล้อม โดยวิธีการคัดแยกขยะในเบื้องต้นมีวิธีดังนี้\n',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(
                                    text: 'แยกขยะตามประเภทหลัก\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '    ขยะทั่วไป: เช่น ถุงพลาสติก หลอด ขวดน้ำแบบใช้ครั้งเดียว\n',
                                  ),
                                  TextSpan(
                                    text:
                                        '    ขยะรีไซเคิล: เช่น ขวดพลาสติก กระป๋องโลหะ กระดาษ\n',
                                  ),
                                  TextSpan(
                                    text:
                                        '    ขยะอินทรีย์: เช่น เศษอาหาร เปลือกผลไม้ ใบไม้\n',
                                  ),
                                  TextSpan(
                                    text:
                                        '    ขยะอันตราย: เช่น แบตเตอรี่ หลอดไฟ ถ่านไฟฉาย\n',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(
                                    text: 'ใช้ถังขยะแยกตามประเภท\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '    จัดเตรียมถังขยะแต่ละประเภทให้ชัดเจนด้วยสีหรือสัญลักษณ์ที่เหมาะสม\n',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'วิธีการลดขยะ ด้วยหลักการ 3R',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                setState(() {
                  _VideoId = _VideoIds[1];
                  print(_VideoId);
                  setYouTubeController();
                });
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ปิด'))
                              ],
                              insetPadding: const EdgeInsets.all(16),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              title: const Text('วิธีการลดขยะด้วยหลักการ 3R'),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(fontSize: 16),
                                          children: const [
                                            TextSpan(
                                              text:
                                                  '    หลักการ 3R หรือลดใช้ ใช้ซ้ำ นำกลับมาใช้ใหม่ เป็นแนวทางในการลดขยะและใช้ทรัพยากรอย่างมีประสิทธิภาพ การปฏิบัติตามหลักการ 3R ช่วยลดปริมาณขยะ ลดการใช้ทรัพยากรธรรมชาติ และสนับสนุนการรักษาสิ่งแวดล้อมในระยะยาว\n',
                                            ),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(fontSize: 16),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'โดยหลักการ 3R ประกอบไปด้วย\n',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style
                                                      .copyWith(fontSize: 16),
                                              children: const [
                                                TextSpan(
                                                  text:
                                                      '    1. Reduce (ลดการใช้) ลดการใช้วัสดุและทรัพยากรที่ไม่จำเป็น เลือกซื้อเฉพาะสิ่งที่จำเป็นและลดการซื้อสินค้าที่ใช้ครั้งเดียว เช่น หลีกเลี่ยงการใช้ถุงพลาสติก และเลือกใช้ถุงผ้าแทน\n',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '    2. Reuse (ใช้ซ้ำ) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว แยกขยะรีไซเคิลอย่างถูกต้อง แยกขยะที่สามารถรีไซเคิลได้ เช่น กระดาษ แก้ว พลาสติก และโลหะ ออกจากขยะอื่น ๆ และนำไปทิ้งในจุดรับขยะรีไซเคิล\n',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '    3. Recycle (นำกลับมาใช้ใหม่) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว ซ่อมแซมสินค้าแทนการทิ้ง หากสินค้าที่เสียหรือชำรุดสามารถซ่อมแซมได้ ให้ซ่อมและใช้งานต่อไปแทนการทิ้งและซื้อใหม่\n',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      YoutubePlayer(
                                        controller: _playerController,
                                        showVideoProgressIndicator: true,
                                        onReady: () {
                                          print('Player is ready.');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )));
              },
              child: SizedBox(
                width: 400,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          'คลิกเพื่ออ่านต่อ...',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 73, 133)),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(
                                    text:
                                        '    หลักการ 3R หรือลดใช้ ใช้ซ้ำ นำกลับมาใช้ใหม่ เป็นแนวทางในการลดขยะและใช้ทรัพยากรอย่างมีประสิทธิภาพ การปฏิบัติตามหลักการ 3R ช่วยลดปริมาณขยะ ลดการใช้ทรัพยากรธรรมชาติ และสนับสนุนการรักษาสิ่งแวดล้อมในระยะยาว\n',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(
                                    text: 'โดยหลักการ 3R ประกอบไปด้วย\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                      text:
                                          '    1. Reduce (ลดการใช้) ลดการใช้วัสดุและทรัพยากรที่ไม่จำเป็น เลือกซื้อเฉพาะสิ่งที่จำเป็นและลดการซื้อสินค้าที่ใช้ครั้งเดียว เช่น หลีกเลี่ยงการใช้ถุงพลาสติก และเลือกใช้ถุงผ้าแทน\n'),
                                  TextSpan(
                                      text:
                                          '    2. Recycle (ใช้ซ้ำ) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว\n'),
                                  TextSpan(
                                      text:
                                          '    3. Recycle (นำกลับมาใช้ใหม่) ใช้ซ้ำสินค้าที่สามารถนำกลับมาใช้ได้ เช่น ใช้ถุงผ้าในการช้อปปิ้ง ใช้ขวดน้ำที่เติมได้แทนขวดน้ำแบบใช้ครั้งเดียว ซ่อมแซมสินค้าแทนการทิ้ง หากสินค้าที่เสียหรือชำรุดสามารถซ่อมแซมได้ ให้ซ่อมและใช้งานต่อไปแทนการทิ้งและซื้อใหม่\n')
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class GridWieget extends StatelessWidget {
  const GridWieget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const GeneralWaste();
              }));
            },
            child: gridItem(
                'ขยะทั่วไป', CustomIcons.general_waste_bin, Colors.blue)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const RecycleWaste();
              }));
            },
            child: gridItem(
                'ขยะรีไซเคิล', CustomIcons.recycle_waste_bin, Colors.amber)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CompostableWaste();
              }));
            },
            child: gridItem('ขยะอินทรีย์', CustomIcons.compostable_waste_bin,
                Colors.green)),
        InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const HazadousWaste();
              }));
            },
            child: gridItem(
                'ขยะอันตราย', CustomIcons.hazadous_waste_bin, Colors.red)),
      ],
    );
  }

  Widget gridItem(String jname, IconData icon, Color iconCol) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              jname,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Icon(
            icon,
            size: 100,
            color: iconCol,
          )
        ],
      ),
    );
  }
}
