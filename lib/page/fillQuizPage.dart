import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'resultPage.dart';

class FillQuiz extends StatefulWidget {
  final String setnum;
  final String chapternum;
  const FillQuiz({Key? key, required this.setnum, required this.chapternum})
      : super(key: key);

  @override
  State<FillQuiz> createState() => _FillQuizState();
}

class _FillQuizState extends State<FillQuiz> {
  final player = AudioPlayer();
  late Stream<QuerySnapshot> _questionsStream;
  late int _currentQuestionIndex = 0;
  late List<DocumentSnapshot> _questions = [];
  late String _correctAnswer = '';
  int _score = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _unansweredCount = 0;

  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '';
  double _progress = 0;

  late bool _showValidationIcon;

  @override
  void initState() {
    super.initState();
    _showValidationIcon = false;
    _questionsStream = FirebaseFirestore.instance
        .collection('questions')
        .where('setnum', isEqualTo: widget.setnum)
        .snapshots();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: const Color(0xFF074173),
          child: Column(
            children: [
              const SizedBox(height: 15),
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
                          const Icon(Icons.timer, color: Colors.white),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            _elapsedTime,
                            style: const TextStyle(
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
                      style: const TextStyle(
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
                        'Skor: $_unansweredCount',
                        style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No questions found.'));
                    }

                    _questions = snapshot.data!.docs;
                    var question = _questions[_currentQuestionIndex];

                    _correctAnswer = question['answer'];

                    return ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return buildFillQuestionWidget(question);
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

  final TextEditingController fillAnswerController = TextEditingController();
  String answer = "";
  Widget validateAnswerWidget(String currentAnswer) {
    IconData icon = CupertinoIcons.add;
    Color iconColor = Colors.transparent;

    if (currentAnswer.isNotEmpty) {
      if (_correctAnswer == currentAnswer) {
        icon = CupertinoIcons.check_mark_circled_solid;
        iconColor = Colors.green;
      } else {
        icon = CupertinoIcons.xmark_circle_fill;
        iconColor = Colors.red;
      }
    }

    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 40,
        ),
      ),
    );
  }

  Widget buildFillQuestionWidget(DocumentSnapshot<Object?> question) {
    String currentAnswer = fillAnswerController.text.trim();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 750,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 15),
              Text(
                question['questString'],
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  color: Color(0xFF074173),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: fillAnswerController,
                decoration: InputDecoration(
                  labelText: 'Enter your answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Update currentAnswer when text field changes
                    currentAnswer = value.trim();
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showValidationIcon = true;
                    if (_correctAnswer == currentAnswer) {
                      player.play(AssetSource('audio/correct.mp3'));
                      _score += 20;
                      _correctCount++;
                    } else {
                      player.play(AssetSource('audio/wrong.mp3'));
                      _wrongCount++;
                    }
                    Future.delayed(const Duration(seconds: 2), () {
                      _navigateToNextQuestion();
                    });
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFF074173),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Semak jawapan',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 3, color: const Color(0xFF074173)),
                          color: Colors.transparent),
                      child: _showValidationIcon
                          ? validateAnswerWidget(currentAnswer)
                          : const SizedBox(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF074173),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _unansweredCount++;
                      });
                      _navigateToNextQuestion();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 300,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFF074173),
                      ),
                      child: const Text(
                        'Soalan Seterusnya',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFC55A)),
            ),
          ),
        ),
      ],
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
