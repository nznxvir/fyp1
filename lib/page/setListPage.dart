import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/fillQuizPage.dart';
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
  late String _chapterTitle;
  late String _chapterid = '';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              height: 100,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Colors.amber),
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
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color(0xFF074173),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 30,
                          weight: 5,
                          color: Colors.amber,
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
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF074173)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              children: [
                const SizedBox(
                  width: 20,
                ),
                _chapterid.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        width: double.infinity,
                        height: 700,
                        color: Colors.white,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('sets')
                              .where('chapter', isEqualTo: _chapterid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );

                            var sets = snapshot.data!.docs;
                            sets.sort(
                                (a, b) => a['setnum'].compareTo(b['setnum']));

                            return ListView.builder(
                              itemCount: sets.length,
                              itemBuilder: (BuildContext context, int index) {
                                QueryDocumentSnapshot<Object?> setDoc =
                                    sets[index];

                                return Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 40, right: 10, left: 10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.8),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
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
                                            color: Color(0xFF074173),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft:
                                                    Radius.circular(15))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Modul',
                                              style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.amber),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              alignment: Alignment.center,
                                              width: 70,
                                              height: 70,
                                              decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                              child: Text(
                                                setDoc['setnum'],
                                                style: const TextStyle(
                                                    fontFamily: 'Rubik',
                                                    fontSize: 52,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bilangan Soalan: ' +
                                                    setDoc['question']
                                                        .toString(),
                                                style: const TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                'Tahap: ' +
                                                    setDoc['difficulty'] +
                                                    ' min',
                                                style: const TextStyle(
                                                    fontFamily: 'Rubik',
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Text(
                                                'Markah: ' +
                                                    setDoc['mark'].toString(),
                                                style: const TextStyle(
                                                    fontFamily: 'Rubik',
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                width: 230,
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      player.play(AssetSource(
                                                          'audio/startquiz.mp3'));
                                                      Future.delayed(
                                                          Duration(seconds: 1),
                                                          () {
                                                        if (setDoc['type'] ==
                                                            'mcq') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => QuizView(
                                                                  setnum: setDoc[
                                                                      'setnum'],
                                                                  chapternum:
                                                                      setDoc[
                                                                          'chapter']),
                                                            ),
                                                          );
                                                        } else if (setDoc[
                                                                'type'] ==
                                                            'fb') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => FillQuiz(
                                                                  setnum: setDoc[
                                                                      'setnum'],
                                                                  chapternum:
                                                                      setDoc[
                                                                          'chapter']),
                                                            ),
                                                          );
                                                        } else if (setDoc[
                                                                'type'] ==
                                                            'tof') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => tofQuiz(
                                                                  setnum: setDoc[
                                                                      'setnum'],
                                                                  chapternum:
                                                                      setDoc[
                                                                          'chapter']),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color(
                                                          0xFF074173), // Use 0xFF as the prefix
                                                    ),
                                                    child: const Text(
                                                      'Mula',
                                                      style: TextStyle(
                                                          fontFamily: 'Rubik',
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.amber),
                                                    )),
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
                        ),
                      )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
