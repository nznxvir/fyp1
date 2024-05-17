import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
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
  late PageController _pageController;

  Color _answerContainerColor = AppColors.backgroundColor;
  final TextEditingController fillAnswerController = TextEditingController();

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
    _pageController = PageController();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
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
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.primaryColor,
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
                            border: Border.all(
                                width: 3, color: AppColors.backgroundColor),
                            color: Colors.transparent),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer,
                                color: AppColors.backgroundColor),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _elapsedTime,
                              style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.backgroundColor),
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
                            color: AppColors.backgroundColor),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                width: 3, color: AppColors.backgroundColor),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Skor: $_unansweredCount',
                          style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 20,
                              color: AppColors.backgroundColor),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 20,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: AppColors.backgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.thirdColor),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: double.infinity,
                  height: 620,
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

                      return PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return buildFillQuestionWidget(_questions[index]);
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentQuestionIndex = index;
                            _progress = (index) / _questions.length;
                            _showValidationIcon = false;
                            fillAnswerController.clear();
                            _answerContainerColor = AppColors.backgroundColor;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget validateAnswerWidget(String currentAnswer) {
    IconData icon = CupertinoIcons.add;
    Color iconColor = Colors.transparent;

    if (currentAnswer.isNotEmpty) {
      String userInputLowercase = currentAnswer.toLowerCase();
      String correctAnswerLowercase = _correctAnswer.toLowerCase();
      if (userInputLowercase == correctAnswerLowercase) {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _answerContainerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 750,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
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
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fillAnswerController,
              decoration: InputDecoration(
                labelText: 'Masukkan jawapan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  currentAnswer = value.trim();
                });
              },
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    String currentAnswer = fillAnswerController.text.trim();
                    if (currentAnswer.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Amaran"),
                            content: Text("Tuliskan jawapan anda."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _showValidationIcon = true;
                      // Convert both user's input and correct answer to lowercase
                      String userInputLowercase = currentAnswer.toLowerCase();
                      String correctAnswerLowercase =
                          _correctAnswer.toLowerCase();
                      if (userInputLowercase == correctAnswerLowercase) {
                        player.play(AssetSource('audio/correct.mp3'));
                        _score += 20;
                        _correctCount++;
                        _answerContainerColor = Colors.green;
                      } else {
                        player.play(AssetSource('audio/wrong.mp3'));
                        _wrongCount++;
                        _answerContainerColor = Colors.red;
                      }
                      Future.delayed(const Duration(seconds: 2), () {
                        if (_currentQuestionIndex < _questions.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Final question, navigate to result page
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
                                elapsedTime: _elapsedTime,
                              ),
                            ),
                          );
                        }
                        _answerContainerColor = AppColors.backgroundColor;
                      });
                    }
                  });
                },
                child: Container(
                  width: 310,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 6, color: AppColors.primaryColor),
                        left: BorderSide(
                            width: 4, color: AppColors.primaryColor)),
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.thirdColor,
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
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    color: AppColors.secondaryColor,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_left),
                    iconSize: 30,
                    color: AppColors.backgroundColor,
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
                      _unansweredCount++;
                      if (_currentQuestionIndex < _questions.length - 1) {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
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
                      }
                      _answerContainerColor = AppColors.backgroundColor;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 240,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.secondaryColor,
                    ),
                    child: const Text(
                      'Soalan Seterusnya',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
