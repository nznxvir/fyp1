import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fyp1/page/historyPage.dart';
import 'package:fyp1/page/profilePage.dart';
import 'package:fyp1/page/Leaderboard/rankPage.dart';
import 'package:fyp1/page/setListPage.dart';
import '../bottomnav.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final user = FirebaseAuth.instance.currentUser!;
  late String username = '';
  late num score = 0;
  late String image = '';
  late num rank = 0;
  late String chapterID = '';
  late int _currentIndex = 1;
  late PageController _pageController;
  late PageController _historyPageController;

  @override
  void initState() {
    super.initState();
    getUserData();
    _pageController = PageController(initialPage: 1);
    _historyPageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _historyPageController.dispose();
    super.dispose();
  }

  void getUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      username = userDoc['username'];
      score = userDoc['score'];
      image = userDoc['imageurl'];
      rank = userDoc['rank'];
    });
    updateChapterUnlockStatus();
  }

  void updateChapterUnlockStatus() async {
    QuerySnapshot chaptersSnapshot =
        await FirebaseFirestore.instance.collection('chapters').get();
    chaptersSnapshot.docs.forEach((chapterDoc) {
      String chapterId = chapterDoc['chapter'];
      bool isUnlock = chapterDoc['isUnlock'];
      // Update isUnlock based on user's score
      if (score < 100 && chapterId != '1') {
        isUnlock = false;
      } else if (score >= 100 && chapterId == '2') {
        isUnlock = true;
      } else if (score >= 200 && chapterId == '3') {
        isUnlock = true;
      }
      // Update isUnlock value in Firestore
      chapterDoc.reference.update({'isUnlock': isUnlock});
    });
  }

  void _onTap(int index) {
    setState(() {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _navigateToHistoryView() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const HistoryView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            RankView(),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: const BoxDecoration(
                            color: Color(0xFF6F131E),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        height: 240,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selamat Datang ',
                                      style: TextStyle(
                                          color: Color(0xFFEEE0C9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Rubik'),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      username,
                                      style: const TextStyle(
                                          color: Color(0xFFEEE0C9),
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Rubik'),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFEEE0C9),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(image))),
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 20, right: 20, left: 20, top: 140),
                        decoration: BoxDecoration(
                          border:
                              Border.all(width: 10, color: Color(0xFFEEE0C9)),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
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
                        alignment: Alignment.bottomCenter,
                        height: 150,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              width: 135,
                              height: 150,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    'Ranking',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    rank.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              width: 135,
                              height: 150,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const Text(
                                    'Markah',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        score.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 60,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'pts',
                                        style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: GestureDetector(
                        onTap: () {
                          _navigateToHistoryView();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6F131E),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
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
                          child: const Text(
                            'Lihat log permainan',
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEEE0C9)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors
                          .white, // Set the default background color to white
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chapters')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot chapter =
                                  snapshot.data!.docs[index];
                              bool isUnlock = chapter['isUnlock'];
                              String imageUrl = chapter[
                                  'imageurl']; // Get the image URL from the database
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 20),
                                    Stack(
                                      children: [
                                        if (!isUnlock)
                                          Container(
                                            height: 170,
                                            width: 370,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              border: Border.all(
                                                  width: 10,
                                                  color:
                                                      const Color(0xFF6F131E)),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20)),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock_rounded,
                                                    size: 50,
                                                    color: Color(0xFFEEE0C9),
                                                  ),
                                                  Text(
                                                    'Kumpul lebih markah untuk membuka topik ini',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () {
                                              _chapterDescribe(
                                                  context, chapter);
                                            },
                                            child: Container(
                                              height: 170,
                                              width: 370,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    width: 10,
                                                    color: const Color(
                                                        0xFF6F131E)),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(20)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.8),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ],
                                                image: DecorationImage(
                                                  image: NetworkImage(imageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 10,
                                                            top: 5,
                                                            bottom: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Bab',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Rubik',
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 60,
                                                              height: 60,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15)),
                                                                color: Color(
                                                                    0xFF6F131E),
                                                              ),
                                                              child: Text(
                                                                chapter[
                                                                    'chapter'],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Rubik',
                                                                  fontSize: 42,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xFFEEE0C9),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          chapter['title'],
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                            fontFamily: 'Rubik',
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}

Future _chapterDescribe(BuildContext context, DocumentSnapshot chapter) {
  void _navigateToListView() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => SetListView(chapterId: chapter.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
            padding: EdgeInsetsDirectional.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Color(0xFF6F131E),
              ),
              width: double.infinity,
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['title'],
                          style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          chapter['description'],
                          style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah modul',
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 80,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '3',
                                    style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    '  modul',
                                    style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateToListView();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          color: Color(0xFFEEE0C9)),
                      child: const Text(
                        'Pilih modul',
                        style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
}
