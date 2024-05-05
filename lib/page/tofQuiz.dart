// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'resultPage.dart';

class tofQuiz extends StatefulWidget {
  final String setnum;
  final String chapternum;
  const tofQuiz({super.key, required this.setnum, required this.chapternum});

  @override
  State<tofQuiz> createState() => _tofQuizState();
}

class _tofQuizState extends State<tofQuiz> {
  final player = AudioPlayer();
  late Stream<QuerySnapshot> _questionsStream;
  late int _currentQuestionIndex = 0;
  late List<DocumentSnapshot> _questions = [];
  late bool _correctAnswer;
  int _score = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _unansweredCount = 0;

  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '';
  double _progress = 0;

  late bool _showValidationIcon;
  late bool currentAnswer = false;

  @override
  void initState() {
    super.initState();
    _showValidationIcon = false;
    _questionsStream = FirebaseFirestore.instance
        .collection('tofquestions')
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

  @override
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

  Widget validateAnswer(bool currentAnswer) {
    IconData icon = CupertinoIcons.add;
    Color iconColor = Colors.transparent;

    if (_correctAnswer == currentAnswer) {
      icon = CupertinoIcons.check_mark_circled_solid;
      iconColor = Colors.green;
    } else {
      icon = CupertinoIcons.xmark_circle_fill;
      iconColor = Colors.red;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 50,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                question['questString'],
                style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    color: Color(0xFF074173),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showValidationIcon = true;
                            currentAnswer = true;
                            if (_correctAnswer == currentAnswer) {
                              player.play(AssetSource('audio/correct.mp3'));
                              _score += 5;
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
                        child: Container(
                          width: 170,
                          alignment: Alignment.center,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.amber[100]),
                          child: const Text('Betul',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontFamily: 'Rubik', fontSize: 23)),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showValidationIcon = true;
                            currentAnswer = false;
                            if (_correctAnswer == currentAnswer) {
                              player.play(AssetSource('audio/correct.mp3'));
                              _score += 5;
                              _correctCount++;
                            } else {
                              player.play(AssetSource('audio/wrong.mp3'));
                              _wrongCount++;
                            }
                            Future.delayed(const Duration(seconds: 3), () {
                              _navigateToNextQuestion();
                            });
                          });
                        },
                        child: Container(
                          width: 170,
                          alignment: Alignment.center,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.amber[100]),
                          child: const Text('Salah',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontFamily: 'Rubik', fontSize: 23)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            width: 5, color: const Color(0xFF074173)),
                        color: Colors.transparent),
                    child: _showValidationIcon
                        ? validateAnswer(currentAnswer)
                        : const SizedBox(),
                  ),
                ],
              ),
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
                  const SizedBox(
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
                            color: const Color(0xFF074173)),
                        child: const Text(
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
