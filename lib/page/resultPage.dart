import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/homePage.dart';

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
  late String _userId = ''; // Variable to store user ID
  late String _username = ''; // Variable to store username
  late int _score = 0; // Variable to store user score

  @override
  void initState() {
    super.initState();
    // Call function to fetch user data when the widget is initialized
    _fetchUserData();
  }

  // Function to fetch user data from Firestore
  void _fetchUserData() async {
    try {
      // Get Firestore instance
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      // Access the data from the snapshot and store it in variables
      var userData = snapshot.data();
      _userId = snapshot.id;
      _username = userData!['username'];
      _score = userData['score'];

      // Update the state to reflect the changes
      setState(() {});
    } catch (error) {
      // Handle any errors that occur during fetching data
      print('Error fetching user data: $error');
    }
  }

  // Function to update user score in Firestore
  void _updateUserScore(int newScore) async {
    try {
      // Get the reference to the document for the current user
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      // Update the score field with the new value
      await userRef.update({'score': newScore});
    } catch (error) {
      // Handle any errors that occur during updating
      print('Error updating user score: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    int answered = 5 - widget.unansweredCount;
    int currentScore = widget.score + _score;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF074173),
        body: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 130, left: 15, right: 15),
                  child: Container(
                    width: 600,
                    height: 670,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.white),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Tahniah',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 50),
                        ),
                        Text(
                          'Markah Diperoleh',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.score.toString(),
                          style: TextStyle(fontSize: 130),
                        ),
                        Text(
                          'Masa menjawab: ${widget.elapsedTime}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                width: 110,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Colors.amber[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      answered.toString(),
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    Container(
                                      width: 60,
                                      child: Text(
                                        'Soalan Dijawab',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  ],
                                )),
                            Container(
                                width: 110,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      widget.correctCount.toString(),
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    Container(
                                      width: 60,
                                      child: Text(
                                        'Betul',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  ],
                                )),
                            Container(
                                width: 110,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      widget.wrongCount.toString(),
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    Container(
                                      width: 60,
                                      child: Text(
                                        'Salah',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Container(
                              width: 250,
                              height: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 5, color: Colors.black)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Skor terkini',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    currentScore.toString(),
                                    style: TextStyle(fontSize: 45),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Color(0xFF074173)),
                                  child: Icon(
                                    Icons.home,
                                    color: Colors.amber,
                                    size: 40,
                                  )),
                              onTap: () {
                                _updateUserScore(currentScore);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeView()),
                                );
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image(
                    image: AssetImage('assets/quiz_bulb.png'),
                    width: 300,
                    height: 170,
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
