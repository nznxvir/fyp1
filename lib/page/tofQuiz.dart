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

  late bool currentAnswer = false;

  late Color _selectedBetulColor = AppColors.thirdColor;
  late Color _selectedSalahColor = AppColors.thirdColor;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
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
    _updateProgress();
    _startTimer();
    _pageController = PageController();
  }

  void _updateProgress() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (_progress < 1.0) {
          _updateProgress();
        }
      });
    });
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              return Column(
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, color: Color(0xFF874CCC)),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(
                                _elapsedTime,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFFC23C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.28,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border:
                                Border.all(width: 4, color: Color(0xFFFFC23C)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Soalan: ${_currentQuestionIndex + 1}',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              color: AppColors.backgroundColor,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _score.toString(),
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFC23C),
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.19,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                child: Image.asset(
                                  'assets/point.png',
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: _progress),
                        duration: Duration(seconds: 1),
                        builder: (context, value, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 20,
                              backgroundColor: AppColors.backgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFC23C)),
                            ),
                          );
                        },
                      )),
                  SizedBox(height: screenHeight * 0.03),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.primaryColor,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _questionsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No questions found.'));
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
                                _selectedBetulColor = AppColors.thirdColor;
                                _selectedSalahColor = AppColors.thirdColor;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildQuestionWidget(DocumentSnapshot<Object?> question) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: screenHeight * 0.02),
          Text(
            question['questString'],
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: screenWidth * 0.052,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
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
                  margin: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05),
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                      border: const Border(
                          bottom: BorderSide(
                              width: 7, color: AppColors.primaryColor),
                          left: BorderSide(
                              width: 4, color: AppColors.primaryColor)),
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedBetulColor),
                  child: Text('Betul',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.1,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
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
                  margin: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05), //
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                      border: const Border(
                          bottom: BorderSide(
                              width: 7, color: AppColors.primaryColor),
                          left: BorderSide(
                              width: 4, color: AppColors.primaryColor)),
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedSalahColor),
                  child: Text('Salah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
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
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  child: Image.asset('assets/quit.png'),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.01,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _unansweredCount++;
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
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.secondaryColor),
                  child: SizedBox(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    child: Image.asset('assets/skip1.png'),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
