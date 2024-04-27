import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/resultPage.dart';

class TestView extends StatefulWidget {
  final String setnum;
  final String chapternum;
  const TestView({Key? key, required this.setnum, required this.chapternum})
      : super(key: key);

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
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

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Container(
          width: 400,
          height: 700,
          color: Colors.white,
          child: Column(
            children: [
              Text(
                'Time Elapsed: $_elapsedTime',
                style: TextStyle(fontSize: 16),
              ),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 20,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _unansweredCount++; // Increment unanswered count
                      });
                      _navigateToNextQuestion(); // Call the function
                    },
                    child: Text('Skip'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestionWidget(DocumentSnapshot<Object?> question) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        height: 600,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['questString'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            buildOptionWidget(_option1),
            SizedBox(height: 20),
            buildOptionWidget(_option2),
            SizedBox(height: 20),
            buildOptionWidget(_option3),
            SizedBox(height: 20),
            buildOptionWidget(_option4),
          ],
        ),
      ),
    );
  }

  Widget buildOptionWidget(String option) {
    bool isSelected = _selectedOption == option;
    bool isCorrect = _correctAnswer == option;

    Color borderColor = Colors.grey;

    if (_selectedOption != null) {
      borderColor = isCorrect
          ? Colors.green
          : isSelected
              ? Colors.red
              : Colors.grey;
    }

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
        width: 330,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
          border: Border.all(
            width: 5,
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Text(
              option,
              style: TextStyle(fontSize: 20),
            ),
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
