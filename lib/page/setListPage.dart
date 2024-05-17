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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteView(
                          chapterid: noteDoc['chapter'], sub: noteDoc['sub']),
                    ),
                  );
                },
                child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 40, right: 10, left: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'SubTopik',
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.thirdColor),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 60,
                                decoration: const BoxDecoration(
                                    color: AppColors.thirdColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Text(
                                  noteDoc['chapter'] + '.' + noteDoc['sub'],
                                  style: const TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 42,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          width: 260,
                          child: Text(
                            noteDoc['title'],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 20,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    )),
              );
            });
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
              margin: const EdgeInsets.only(bottom: 40, right: 10, left: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 160,
                    decoration: const BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Modul',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.thirdColor),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                              color: AppColors.thirdColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: Text(
                            setDoc['setnum'],
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 52,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bilangan Soalan: ' + setDoc['question'].toString(),
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tahap: ' + setDoc['difficulty'] + ' min',
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 18,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Markah: ' + setDoc['mark'].toString(),
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 18,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700),
                          ),
                          GestureDetector(
                            onTap: () {
                              player.play(AssetSource('audio/startquiz.mp3'));
                              Future.delayed(Duration(seconds: 1), () {
                                if (setDoc['type'] == 'mcq') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizView(
                                          setnum: setDoc['setnum'],
                                          chapternum: setDoc['chapter']),
                                    ),
                                  );
                                } else if (setDoc['type'] == 'fb') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FillQuiz(
                                          setnum: setDoc['setnum'],
                                          chapternum: setDoc['chapter']),
                                    ),
                                  );
                                } else if (setDoc['type'] == 'tof') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => tofQuiz(
                                          setnum: setDoc['setnum'],
                                          chapternum: setDoc['chapter']),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
                              width: 230,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: AppColors.secondaryColor),
                              child: const Text(
                                'Mula',
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.thirdColor),
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
                    margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                    width: double.infinity,
                    height: 80,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 4, color: AppColors.secondaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: AppColors.thirdColor),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: AppColors.secondaryColor,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 30,
                                weight: 5,
                                color: AppColors.thirdColor,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          height: 90,
                          width: 300,
                          child: Text(
                            _chapterTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
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
                              height: 765,
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
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                height: 80,
                decoration: BoxDecoration(
                    border: Border.all(width: 5, color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.thirdColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.quiz),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                            },
                            color: _selectedIndex == 0
                                ? AppColors.primaryColor
                                : AppColors.backgroundColor),
                        if (_selectedIndex == 0)
                          Text('Kuiz',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: 'Rubik',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.note),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 1;
                              });
                            },
                            color: _selectedIndex == 1
                                ? AppColors.primaryColor
                                : AppColors.backgroundColor),
                        if (_selectedIndex == 1)
                          Text('Nota',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: 'Rubik',
                                  fontSize: 14,
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
