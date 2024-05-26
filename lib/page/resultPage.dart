import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/homePage.dart';
import 'package:lottie/lottie.dart';

import 'rankUtils.dart';

class ResultView extends StatefulWidget {
  final int correctCount;
  final int score;
  final int wrongCount;
  final String setnum;
  final int unansweredCount;
  final String chapter;
  final String elapsedTime;

  const ResultView(
      {Key? key,
      required this.correctCount,
      required this.score,
      required this.wrongCount,
      required this.setnum,
      required this.unansweredCount,
      required this.chapter,
      required this.elapsedTime})
      : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final user = FirebaseAuth.instance.currentUser!;
  late String _userId = '';
  late String _username = '';
  late int _score = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      var userData = snapshot.data();
      _userId = snapshot.id;
      _username = userData!['username'];
      _score = userData['score'];
      setState(() {});
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void _updateUserScore(int newScore) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({'score': newScore});
    } catch (error) {
      print('Error updating user score: $error');
    }
  }

  void _storeInHistory() async {
    try {
      DateTime now = DateTime.now();
      String currentDate = '${now.year}-${now.month}-${now.day}';
      String currentTime = '${now.hour}:${now.minute}:${now.second}';
      await FirebaseFirestore.instance.collection('history').add({
        'userId': user.uid,
        'username': _username,
        'correctCount': widget.correctCount,
        'score': widget.score,
        'wrongCount': widget.wrongCount,
        'unansweredCount': widget.unansweredCount,
        'setnum': widget.setnum,
        'chapter': widget.chapter,
        'timeSpent': widget.elapsedTime,
        'currentDate': currentDate,
        'currentTime': currentTime,
      });
    } catch (error) {
      print('Error storing in history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    int answered = 5 - widget.unansweredCount;
    int currentScore = widget.score + _score;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: screenWidth * 0.88,
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 130),
                        child: Container(
                          width: screenWidth * 0.9,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: AppColors.backgroundColor),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Text(
                                'Tahniah',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: screenHeight * 0.05,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Markah Diperoleh',
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 5),
                              Text(
                                widget.score.toString(),
                                style: TextStyle(
                                    fontSize: screenHeight * 0.15,
                                    fontFamily: 'Rubik'),
                              ),
                              Text(
                                'Masa menjawab: ${widget.elapsedTime}',
                                style: TextStyle(
                                    fontSize: screenHeight * 0.025,
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  StatCard(
                                    label: 'Soalan Dijawab',
                                    value: answered.toString(),
                                    color: Color.fromARGB(255, 244, 216, 138),
                                  ),
                                  StatCard(
                                    label: 'Betul',
                                    value: widget.correctCount.toString(),
                                    color: Colors.green[400]!,
                                  ),
                                  StatCard(
                                    label: 'Salah',
                                    value: widget.wrongCount.toString(),
                                    color: Colors.red[400]!,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Column(
                                children: [
                                  Container(
                                    width: 250,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 7,
                                                color: AppColors.primaryColor),
                                            left: BorderSide(
                                                width: 5,
                                                color: AppColors.primaryColor)),
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.thirdColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          'Skor terkini',
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontFamily: 'Rubik'),
                                        ),
                                        Text(
                                          currentScore.toString(),
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontFamily: 'Rubik'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 100,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: AppColors.secondaryColor,
                                      ),
                                      child: _isLoading
                                          ? CircularProgressIndicator(
                                              color: AppColors.thirdColor)
                                          : Icon(
                                              Icons.home,
                                              color: AppColors.thirdColor,
                                              size: 40,
                                            ),
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      _updateUserScore(currentScore);
                                      await updateRank();
                                      _storeInHistory();

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 400),
                                          pageBuilder: (_, __, ___) =>
                                              const HomeView(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            final begin =
                                                const Offset(0.0, 1.0);
                                            final end = Offset.zero;
                                            final curve = Curves.easeInOut;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Lottie.asset('assets/animation/congrat.json',
                          repeat: false),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Image(
                          image: AssetImage('assets/quiz_bulb.png'),
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: 110,
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: screenHeight * 0.05,
              fontFamily: 'Rubik',
            ),
          ),
          Container(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenHeight * 0.017,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
