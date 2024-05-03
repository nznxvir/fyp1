import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'quizPage.dart';

class SetListView extends StatefulWidget {
  final String chapterId;

  SetListView({Key? key, required this.chapterId}) : super(key: key);

  @override
  State<SetListView> createState() => _SetListViewState();
}

class _SetListViewState extends State<SetListView> {
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
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Colors.amber),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color(0xFF074173),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 30,
                          weight: 5,
                          color: Colors.amber,
                        )),
                  ),
                  SizedBox(width: 10),
                  Container(
                    alignment: Alignment.center,
                    height: 90,
                    width: 300,
                    child: Text(
                      _chapterTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF074173)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              children: [
                SizedBox(
                  width: 20,
                ),
                _chapterid.isEmpty
                    ? Center(
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
                              return Center(
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
                                  margin: EdgeInsets.only(
                                      bottom: 40, right: 10, left: 10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.8),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(
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
                                        decoration: BoxDecoration(
                                            color: Color(0xFF074173),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft:
                                                    Radius.circular(15))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Modul',
                                              style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.amber),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 10),
                                              alignment: Alignment.center,
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                              child: Text(
                                                setDoc['setnum'],
                                                style: TextStyle(
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
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                'Masa: ' +
                                                    setDoc['time'].toString() +
                                                    ' min',
                                                style: TextStyle(
                                                    fontFamily: 'Rubik',
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Text(
                                                'Markah: ' +
                                                    setDoc['mark'].toString(),
                                                style: TextStyle(
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
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              QuizView(
                                                                  setnum: setDoc[
                                                                      'setnum'],
                                                                  chapternum:
                                                                      setDoc[
                                                                          'chapter']),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Color(
                                                          0xFF074173), // Use 0xFF as the prefix
                                                    ),
                                                    child: Text(
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
