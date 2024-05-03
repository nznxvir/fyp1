import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/resultPage.dart';

class QuizView extends StatefulWidget {
  final String setnum;
  final String chapternum;

  const QuizView({Key? key, required this.setnum, required this.chapternum})
      : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late Stream<QuerySnapshot> _questionsStream;
  late int _currentQuestionIndex = 0;
  late List<DocumentSnapshot> _questions = [];
  late String _option1 = '';
  late String _option2 = '';
  late String _option3 = '';
  late String _option4 = '';
  late String _correctAnswer = '';
  String? _selectedOption;
  int _score = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _unansweredCount = 0;

  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _questionsStream = FirebaseFirestore.instance
        .collection('questions')
        .where('setnum', isEqualTo: widget.setnum)
        .snapshots();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _formatTime(_stopwatch.elapsed);
      });
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch.start();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget build(BuildContext context) {
    int totalQuestions = _questions.length;
    double progressPercentage = _currentQuestionIndex / totalQuestions;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Color(0xFF074173),
          child: Column(
            children: [
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(width: 3, color: Colors.white),
                          color: Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.white),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            _elapsedTime,
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Soalan: ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 23,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 3, color: Colors.white),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Skor: $_score',
                        style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _questionsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No questions found.'));
                    }

                    _questions = snapshot.data!.docs;
                    var question = _questions[_currentQuestionIndex];
                    _option1 = question['option1'];
                    _option2 = question['option2'];
                    _option3 = question['option3'];
                    _option4 = question['option4'];
                    _correctAnswer = question['answer'];

                    return ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return buildQuestionWidget(question);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestionWidget(DocumentSnapshot<Object?> question) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 750,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                question['questString'],
                style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    color: Color(0xFF074173),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              buildOptionWidget(_option1),
              SizedBox(height: 10),
              buildOptionWidget(_option2),
              SizedBox(height: 10),
              buildOptionWidget(_option3),
              SizedBox(height: 10),
              buildOptionWidget(_option4),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFF074173),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.keyboard_double_arrow_left),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _unansweredCount++; // Increment unanswered count
                        });
                        _navigateToNextQuestion();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 300,
                        height: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFF074173)),
                        child: Text(
                          'Soalan Seterusnya',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -5,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 20,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC55A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOptionWidget(String option) {
    bool isSelected = _selectedOption == option;
    bool isCorrect = _correctAnswer == option;

    Color borderColor = Color(0xFF074173);
    Color color = Colors.transparent;
    IconData iconData = CupertinoIcons.add;
    Color iconColor = Colors.transparent;

    if (_selectedOption != null) {
      iconData = isCorrect
          ? CupertinoIcons.check_mark_circled_solid
          : isSelected
              ? CupertinoIcons.xmark_circle_fill
              : CupertinoIcons.add;
      iconColor = isCorrect
          ? Colors.green
          : isSelected
              ? Colors.red
              : Colors.transparent;
      color = isCorrect
          ? const Color.fromRGBO(232, 245, 233, 1)
          : isSelected
              ? const Color.fromRGBO(255, 235, 238, 1)
              : Colors.transparent;
      borderColor = isCorrect
          ? Colors.green
          : isSelected
              ? Colors.red
              : Color(0xFF074173);
    }

    // Define the icon based on the isCorrect condition

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
          if (isCorrect) {
            _score += 10;
            _correctCount++;
          } else {
            _wrongCount++;
          }
          Future.delayed(Duration(seconds: 1), () {
            _selectedOption = null;
            _navigateToNextQuestion();
          });
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 15),
        width: 400,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            width: 3,
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 300,
              color: Colors.transparent,
              child: Text(
                option,
                style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.transparent),
              child: Center(
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 40, // Adjust size as needed
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _progress = (_currentQuestionIndex) / _questions.length;
      } else {
        print('Quiz completed!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultView(
                score: _score,
                correctCount: _correctCount,
                wrongCount: _wrongCount,
                unansweredCount: _unansweredCount,
                setnum: widget.setnum,
                chapter: widget.chapternum,
                elapsedTime: _elapsedTime),
          ),
        );
        return;
      }
    });
  }
}
