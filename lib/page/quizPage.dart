import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
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
  final player = AudioPlayer();
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

  late PageController _pageController;

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
    _startTimer();
    _updateProgress();

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
        backgroundColor: AppColors.primaryColor,
        body: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            width: MediaQuery.of(context).size.width * 0.02),
                        Text(
                          _elapsedTime,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: MediaQuery.of(context).size.width * 0.05,
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
                      border: Border.all(width: 4, color: Color(0xFFFFC23C)),
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
                          fontSize: MediaQuery.of(context).size.width * 0.06,
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFC23C)),
                      ),
                    );
                  },
                )),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
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
                          _progress = index / _questions.length;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionWidget(DocumentSnapshot<Object?> question) {
    _option1 = question['option1'];
    _option2 = question['option2'];
    _option3 = question['option3'];
    _option4 = question['option4'];
    _correctAnswer = question['answer'];

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      padding: EdgeInsets.only(
          left: screenWidth * 0.03,
          right: screenWidth * 0.03,
          bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Text(
            question['questString'],
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: screenWidth * 0.05,
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          buildOptionWidget(_option1),
          SizedBox(height: screenHeight * 0.015),
          buildOptionWidget(_option2),
          SizedBox(height: screenHeight * 0.015),
          buildOptionWidget(_option3),
          SizedBox(height: screenHeight * 0.015),
          buildOptionWidget(_option4),
          SizedBox(height: screenHeight * 0.02),
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
                width: screenWidth * 0.005,
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
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.secondaryColor,
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    child: Image.asset('assets/skip1.png'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionWidget(String option) {
    bool isSelected = _selectedOption == option;
    bool isCorrect = _correctAnswer == option;

    Color borderColor = AppColors.secondaryColor;
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
              : AppColors.secondaryColor;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
          if (isCorrect) {
            player.play(AssetSource('audio/correctanswer.mp3'));
            _score += 10;
            _correctCount++;
          } else {
            player.play(AssetSource('audio/wrong.mp3'));
            _wrongCount++;
          }
          Future.delayed(const Duration(seconds: 1), () {
            _selectedOption = null;
            if (_currentQuestionIndex < _questions.length - 1) {
              _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            } else {
              _navigateResult();
            }
          });
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: screenWidth * 0.02),
        width: double.infinity,
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 4,
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.65,
              color: Colors.transparent,
              child: Text(
                option,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: screenWidth * 0.051,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: screenWidth * 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
