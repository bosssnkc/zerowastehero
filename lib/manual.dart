import 'package:flutter/material.dart';
import 'package:widget_zoom/widget_zoom.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
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
        elevation: 0,
        title: const Text(
          'คู่มือการใช้งาน',
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
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/1.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/2.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/3.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/4.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/4_1.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/5.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/5_1.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/5_2.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/6.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/7.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/8.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/9.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/10.jpg')),
                ),
                SizedBox(
                  height: 8,
                ),
                WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: Image(image: AssetImage('assets/image/11.jpg')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
