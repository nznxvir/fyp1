import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
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

  late Color _betulColor = AppColors.thirdColor;
  late Color _salahColor = AppColors.thirdColor;
  late Color _selectedBetulColor = AppColors.thirdColor;
  late Color _selectedSalahColor = AppColors.thirdColor;

  late PageController _pageController;

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

  _navigateResult() {
    player.play(AssetSource('audio/finishquiz.mp3'));
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => ResultView(
              score: _score,
              correctCount: _correctCount,
              wrongCount: _wrongCount,
              unansweredCount: _unansweredCount,
              setnum: widget.setnum,
              chapter: widget.chapternum,
              elapsedTime: _elapsedTime),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
              const SizedBox(
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
                      AppColors.secondaryColor),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Container(
                width: double.infinity,
                height: 600,
                color: AppColors.primaryColor,
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
                        return buildQuestionWidget(_questions[index]);
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentQuestionIndex = index;
                          _progress = (index) / _questions.length;
                          _showValidationIcon = false;
                          _selectedBetulColor = AppColors.thirdColor;
                          _selectedSalahColor = AppColors.thirdColor;
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
    );
  }

  Widget buildQuestionWidget(DocumentSnapshot<Object?> question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 55,
          ),
          Text(
            question['questString'],
            style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showValidationIcon = true;
                    currentAnswer = true;
                    if (_correctAnswer == currentAnswer) {
                      player.play(AssetSource('audio/correctanswer.mp3'));
                      _score += 5;
                      _correctCount++;
                      _selectedBetulColor = Colors.green;
                    } else {
                      player.play(AssetSource('audio/wrong.mp3'));
                      _wrongCount++;
                      _selectedBetulColor = Colors.red;
                    }
                    Future.delayed(const Duration(seconds: 1), () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        _navigateResult();
                      }
                    });
                  });
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 7, color: AppColors.primaryColor),
                          left: BorderSide(
                              width: 4, color: AppColors.primaryColor)),
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedBetulColor),
                  child: const Text('Betul',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 23,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showValidationIcon = true;
                    currentAnswer = false;
                    if (_correctAnswer == currentAnswer) {
                      player.play(AssetSource('audio/correctanswer.mp3'));
                      _score += 5;
                      _correctCount++;
                      _selectedSalahColor = Colors.green;
                    } else {
                      player.play(AssetSource('audio/wrong.mp3'));
                      _wrongCount++;
                      _selectedSalahColor = Colors.red;
                    }
                    Future.delayed(const Duration(seconds: 1), () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        _navigateResult();
                      }
                    });
                  });
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 7, color: AppColors.primaryColor),
                          left: BorderSide(
                              width: 4, color: AppColors.primaryColor)),
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedSalahColor),
                  child: const Text('Salah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 23,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  player.play(AssetSource('audio/pop.mp3'));
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                  });
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/quit.png'),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _unansweredCount++; // Increment unanswered count
                      if (_currentQuestionIndex < _questions.length - 1) {
                        player.play(AssetSource('audio/skip.mp3'));
                        Future.delayed(Duration(milliseconds: 500), () {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        });
                      } else {
                        _navigateResult();
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 250,
                    height: 55,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.secondaryColor),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/skip.png'),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
