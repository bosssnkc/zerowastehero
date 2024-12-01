import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:zerowastehero/Routes/routes.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = List.filled(5, null); // คำตอบที่ผู้ใช้งานเลือก
  int currentQuestionIndex = 0;
  bool isLoading = true;
  double _quizProgress = 0.2;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse(getquiz),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'App-Source': appsource
        });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.shuffle(); //สุ่มคำถาม 5 มาคำถามจากทั้งหมดใน Database
      setState(() {
        questions = data.take(5).cast<Map<String, dynamic>>().toList();
        isLoading = false;
      });
    } else {
      throw Exception('โหลดคำถามไม่สำเร็จลองอีกครั้ง');
    }
  }

  void checkResults() {
    // ตรวจสอบว่ามีคำถามข้อไหนที่ยังไม่ได้ตอบ
    int firstUnansweredIndex =
        selectedAnswers.indexWhere((answer) => answer == null);

    if (firstUnansweredIndex != -1) {
      // ถ้ายังมีข้อที่ไม่ได้ตอบ แสดงข้อความแจ้งเตือน
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: const EdgeInsets.all(8),
          title: const Text('คำตอบไม่ครบ'),
          content: Text(
            'โปรดตอบคำถามให้ครบทุกข้อก่อนส่งคำตอบ\n'
            'คุณไม่ได้ตอบคำถามข้อที่ ${firstUnansweredIndex + 1}.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                // ตั้งค่า currentQuestionIndex ให้กลับไปที่ข้อที่ไม่ได้ตอบ
                setState(() {
                  currentQuestionIndex = firstUnansweredIndex;
                  _quizProgress = (currentQuestionIndex + 1) / 5;
                  print('คำตอบที่ยังไม่ตอบ is $firstUnansweredIndex');
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      String correctAnswer = questions[i]['correct_ans'];
      // นำเฉลยมาเปรียบเทียบกับคำตอบที่ผู้ใช้งานเลือก
      int? selectedAnswerIndex = selectedAnswers[i];
      String? selectedAnswerText = selectedAnswerIndex != null
          ? questions[i]['quiz_ans${selectedAnswerIndex}']
          : null;

      if (selectedAnswerText == correctAnswer) {
        correctAnswers++;
      }
    }

    bool passed = correctAnswers >= 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(passed ? 'ยินดีด้วย!' : 'พยายามเข้า..'),
        content: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: passed ? Colors.green : Colors.red,
              ),
              Text(
                'คุณ${passed ? 'ผ่าน!' : 'ไม่ผ่าน..'} \nคุณตอบคำถามถูก $correctAnswers ข้อ จากทั้งหมด 5 ข้อ',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      _quizProgress = (currentQuestionIndex + 1) / 5;
      print(_quizProgress);
    });
  }

  void previousQuestion() {
    setState(() {
      currentQuestionIndex--;
      _quizProgress = (currentQuestionIndex + 1) / 5;
      print(_quizProgress);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        title: const Text(
          'แบบทดสอบวัดความรู้',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/image/zwh_bg.png'), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'คำถามที่ ${currentQuestionIndex + 1}/5',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _quizProgress,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                                backgroundColor: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(5),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${question['quiz_name']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Column(
                          children: List<Widget>.generate(4, (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: RadioListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                activeColor: Colors.green,
                                title: Text(question['quiz_ans${index + 1}']),
                                value: index + 1,
                                groupValue:
                                    selectedAnswers[currentQuestionIndex],
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedAnswers[currentQuestionIndex] =
                                        value;
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (currentQuestionIndex > 0)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white),
                                  onPressed: previousQuestion,
                                  child: const Text('คำถามก่อนหน้า')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white),
                                onPressed: currentQuestionIndex < 4
                                    ? nextQuestion
                                    : checkResults,
                                child: Text(currentQuestionIndex < 4
                                    ? 'คำถามถัดไป'
                                    : 'ส่งคำตอบ'))
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
