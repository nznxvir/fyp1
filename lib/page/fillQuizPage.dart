import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';
import 'resultPage.dart';

class FillQuiz extends StatefulWidget {
  final String setnum;
  final String chapternum;
  const FillQuiz({super.key, required this.setnum, required this.chapternum});

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

  late PageController _pageController;

  Color _answerContainerColor = AppColors.backgroundColor;
  final TextEditingController fillAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _updateProgress();
    _startTimer();
    _pageController = PageController();
  }

  void _updateProgress() {
    Future.delayed(const Duration(seconds: 1), () {
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
    Future.delayed(const Duration(milliseconds: 500), () {
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
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.primaryColor,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
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
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
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
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
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
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: Image.asset(
                                'assets/point.png',
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.73,
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
                      _correctAnswer = question['answer'];

                      return PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return buildFillQuestionWidget(_questions[index]);
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentQuestionIndex = index;
                            _progress = (index) / _questions.length;
                            fillAnswerController.clear();
                            _answerContainerColor = AppColors.backgroundColor;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFillQuestionWidget(DocumentSnapshot<Object?> question) {
    fillAnswerController.text.trim();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: _answerContainerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              question['questString'],
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: screenWidth * 0.05,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            TextField(
              controller: fillAnswerController,
              decoration: InputDecoration(
                labelText: 'Masukkan jawapan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {});
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
                            backgroundColor: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Tuliskan jawapan anda.",
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      String userInputLowercase = currentAnswer.toLowerCase();
                      String correctAnswerLowercase =
                          _correctAnswer.toLowerCase();
                      if (userInputLowercase == correctAnswerLowercase) {
                        player.play(AssetSource('audio/correctanswer.mp3'));
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
                          _navigateResult();
                        }
                        _answerContainerColor = AppColors.backgroundColor;
                      });
                    }
                  });
                },
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:
                          BorderSide(width: 6, color: AppColors.primaryColor),
                      left: BorderSide(width: 4, color: AppColors.primaryColor),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.thirdColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Semak jawapan',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: screenWidth * 0.05,
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
            SizedBox(height: screenHeight * 0.03),
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
                    height: screenHeight * 0.05,
                    child: Image.asset('assets/quit.png'),
                  ),
                ),
                SizedBox(width: screenWidth * 0.005),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _unansweredCount++; // Increment unanswered count
                      if (_currentQuestionIndex < _questions.length - 1) {
                        player.play(AssetSource('audio/skip.mp3'));
                        Future.delayed(Duration(milliseconds: 500), () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        });
                      } else {
                        _navigateResult();
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.055,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.secondaryColor,
                    ),
                    child: SizedBox(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.04,
                      child: Image.asset('assets/skip1.png'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
