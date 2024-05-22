import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/funFact.dart';

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
  String username = '';
  num score = 0;
  String image = '';
  num rank = 0;
  late String chapterID = '';
  late int _currentIndex = 1;
  late PageController _pageController;
  late PageController _historyPageController;
  final player = AudioPlayer();

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _navigateToHistoryView() {
    player.play(AssetSource('audio/button.mp3'));
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const HistoryView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = const Offset(0.0, 1.0);
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
    });
  }

  void _navigateToFactsView() {
    player.play(AssetSource('audio/button.mp3'));
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const FactsView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = const Offset(0.0, 1.0);
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
    });
  }

  void resetPage() {
    setState(() {
      getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    num currrank = rank;
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              const RankView(),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selamat Datang ',
                                        style: TextStyle(
                                            color: AppColors.thirdColor,
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
                                            color: AppColors.thirdColor,
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
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 4,
                                            color: AppColors.thirdColor),
                                        color: AppColors.secondaryColor,
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
                            border: Border.all(
                                width: 10, color: AppColors.secondaryColor),
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
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
                                color: AppColors.backgroundColor,
                                width: 135,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    const Text(
                                      'Ranking',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      currrank.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          score.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontFamily: 'Rubik',
                                              fontSize: 50,
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
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _navigateToFactsView();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 140,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    border: const Border(
                                        bottom: BorderSide(
                                            width: 10,
                                            color: AppColors.secondaryColor),
                                        left: BorderSide(
                                            width: 6,
                                            color: AppColors.secondaryColor)),
                                    color: AppColors.backgroundColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.9),

                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      )
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        alignment: Alignment.center,
                                        width: 80,
                                        height: 80,
                                        image: AssetImage(
                                          'assets/fact.png',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Fakta',
                                        style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor),
                                      ),
                                    ],
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                _navigateToHistoryView();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 140,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    border: const Border(
                                        bottom: BorderSide(
                                            width: 10,
                                            color: AppColors.secondaryColor),
                                        left: BorderSide(
                                            width: 6,
                                            color: AppColors.secondaryColor)),
                                    color: AppColors.backgroundColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.9),

                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      )
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        alignment: Alignment.center,
                                        width: 80,
                                        height: 80,
                                        image: AssetImage(
                                          'assets/record.png',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Rekod',
                                        style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: AppColors.backgroundColor,
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
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
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
                                                color: AppColors.thirdColor
                                                    .withAlpha(200),
                                                border: Border.all(
                                                    width: 10,
                                                    color:
                                                        AppColors.primaryColor),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(20)),
                                              ),
                                              child: const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.lock_rounded,
                                                      size: 50,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                    Text(
                                                      'Kumpul lebih markah untuk membuka topik ini',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: AppColors
                                                            .secondaryColor,
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
                                                player.play(AssetSource(
                                                    'audio/pop.mp3'));

                                                Future.delayed(
                                                    Duration(milliseconds: 500),
                                                    () {
                                                  _chapterDescribe(
                                                      context, chapter);
                                                });
                                              },
                                              child: Container(
                                                height: 170,
                                                width: 370,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: const Border(
                                                      bottom: BorderSide(
                                                          width: 12,
                                                          color: AppColors
                                                              .primaryColor),
                                                      left: BorderSide(
                                                          width: 9,
                                                          color: AppColors
                                                              .primaryColor)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 3),
                                                    )
                                                  ],
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(imageUrl),
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
                                                                'Topik',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Rubik',
                                                                  color: AppColors
                                                                      .backgroundColor,
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
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15)),
                                                                  color: AppColors
                                                                      .thirdColor,
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
                                                                    fontSize:
                                                                        42,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Text(
                                                            chapter['title'],
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Rubik',
                                                                fontSize: 23,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .backgroundColor),
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
              const ProfileView(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _onTap(index);
                resetPage();
              })),
    );
  }
}

Future _chapterDescribe(BuildContext context, DocumentSnapshot chapter) {
  final sound = AudioPlayer();
  void _navigateToListView() {
    sound.play(AssetSource('audio/button.mp3'));
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => SetListView(chapterId: chapter.id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = const Offset(0.0, 1.0);
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
    });
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
                color: AppColors.primaryColor,
              ),
              width: double.infinity,
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 1,
                  ),
                  Container(
                    width: 130,
                    height: 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.thirdColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['title'],
                          style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.backgroundColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          chapter['description'],
                          style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.backgroundColor),
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
                                    color: AppColors.backgroundColor),
                              ),
                              SizedBox(
                                height: 60,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '3',
                                    style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.backgroundColor),
                                  ),
                                  Text(
                                    '  modul',
                                    style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.backgroundColor),
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
                      height: 55,
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
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
}
