import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/fillQuizPage.dart';
import 'package:fyp1/page/noteView.dart';
import 'package:fyp1/page/tofQuiz.dart';

import 'quizPage.dart';

class SetListView extends StatefulWidget {
  final String chapterId;

  SetListView({Key? key, required this.chapterId}) : super(key: key);

  @override
  State<SetListView> createState() => _SetListViewState();
}

class _SetListViewState extends State<SetListView> {
  final player = AudioPlayer();
  late String _chapterTitle = '';
  late String _chapterid = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _chapterTitle = '';
    _fetchChapterTitle();
  }

  void _fetchChapterTitle() async {
    if (widget.chapterId.isNotEmpty) {
      final DocumentSnapshot chapterDoc = await FirebaseFirestore.instance
          .collection('chapters')
          .doc(widget.chapterId)
          .get();
      setState(() {
        _chapterTitle = chapterDoc['title'];
        _chapterid = chapterDoc['chapter'];
      });
    }
  }

  Widget _buildNotesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('chapter', isEqualTo: _chapterid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No notes available'),
          );
        }

        var notes = snapshot.data!.docs;
        notes.sort((a, b) => a['sub'].compareTo(b['sub']));

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot<Object?> noteDoc = notes[index];
            return GestureDetector(
              onTap: () {
                player.play(AssetSource('audio/button.mp3'));
                Future.delayed(Duration(milliseconds: 500), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => NoteView(
                          chapterid: noteDoc['chapter'], sub: noteDoc['sub']),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 40, right: 10, left: 10),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'SubTopik',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.w900,
                              color: AppColors.thirdColor,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.02),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              color: AppColors.thirdColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Text(
                              noteDoc['chapter'] + '.' + noteDoc['sub'],
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.08,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      width: MediaQuery.of(context).size.width * 0.63,
                      child: Text(
                        noteDoc['title'],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('sets')
          .where('chapter', isEqualTo: _chapterid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No quiz sets available'),
          );
        }

        var sets = snapshot.data!.docs;
        // Handle sets where "setnum" field is missing or invalid

        sets.sort((a, b) => a['setnum'].compareTo(b['setnum']));

        return ListView.builder(
          itemCount: sets.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot<Object?> setDoc = sets[index];
            // Build each list item here
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.36,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.05,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: MediaQuery.of(context).size.width * 0.003,
                    blurRadius: MediaQuery.of(context).size.width * 0.01,
                    offset: Offset(0, MediaQuery.of(context).size.width * 0.01),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.24,
                    height: MediaQuery.of(context).size.width * 0.36,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          MediaQuery.of(context).size.width * 0.04,
                        ),
                        bottomLeft: Radius.circular(
                          MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Modul',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: MediaQuery.of(context).size.width * 0.055,
                            fontWeight: FontWeight.w900,
                            color: AppColors.thirdColor,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.025),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            color: AppColors.thirdColor,
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                          child: Text(
                            setDoc['setnum'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: MediaQuery.of(context).size.width * 0.1,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Text(
                            'Bilangan Soalan: ' + setDoc['question'].toString(),
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Tahap: ' + setDoc['difficulty'],
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Markah: ' + setDoc['mark'].toString(),
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              player.play(AssetSource('audio/startquiz.mp3'));
                              Future.delayed(Duration(milliseconds: 500), () {
                                if (setDoc['type'] == 'mcq') {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                      pageBuilder: (_, __, ___) => QuizView(
                                        setnum: setDoc['setnum'],
                                        chapternum: setDoc['chapter'],
                                      ),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                        var begin = const Offset(1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else if (setDoc['type'] == 'fb') {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                      pageBuilder: (_, __, ___) => FillQuiz(
                                        setnum: setDoc['setnum'],
                                        chapternum: setDoc['chapter'],
                                      ),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                        var begin = const Offset(1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else if (setDoc['type'] == 'tof') {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                      pageBuilder: (_, __, ___) => tofQuiz(
                                        setnum: setDoc['setnum'],
                                        chapternum: setDoc['chapter'],
                                      ),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                        var begin = const Offset(1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.width * 0.02),
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.58,
                              height: MediaQuery.of(context).size.width * 0.08,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width * 0.02,
                                ),
                                color: AppColors.secondaryColor,
                              ),
                              child: Text(
                                'Mula',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.thirdColor,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.width * 0.04,
                      right: MediaQuery.of(context).size.width * 0.04,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.1,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: AppColors.secondaryColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: AppColors.thirdColor,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            player.play(AssetSource('audio/pop.mp3'));
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                            ),
                            width: MediaQuery.of(context).size.width * 0.12,
                            height: MediaQuery.of(context).size.width * 0.12,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: AppColors.secondaryColor,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: MediaQuery.of(context).size.width * 0.05,
                              color: AppColors.thirdColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                          ),
                          alignment: Alignment.centerLeft,
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.width * 0.67,
                          child: Text(
                            _chapterTitle,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.057,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      _chapterid.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height -
                                  10 -
                                  80 -
                                  MediaQuery.of(context).padding.top -
                                  MediaQuery.of(context).padding.bottom,
                              color: AppColors.backgroundColor,
                              child: _selectedIndex == 0
                                  ? _buildQuizList()
                                  : _buildNotesList(),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.07,
                    0,
                    MediaQuery.of(context).size.width * 0.07,
                    MediaQuery.of(context).size.width * 0.02),
                height: MediaQuery.of(context).size.width * 0.215,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 5, color: AppColors.secondaryColor),
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.thirdColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                            iconSize: MediaQuery.of(context).size.width * 0.06,
                            icon: Icon(Icons.quiz),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                            },
                            color: _selectedIndex == 0
                                ? AppColors.primaryColor
                                : Colors.grey),
                        if (_selectedIndex == 0)
                          Text('Kuiz',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        IconButton(
                            iconSize: MediaQuery.of(context).size.width * 0.06,
                            icon: Icon(Icons.note),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 1;
                              });
                            },
                            color: _selectedIndex == 1
                                ? AppColors.primaryColor
                                : Colors.grey),
                        if (_selectedIndex == 1)
                          Text('Nota',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
