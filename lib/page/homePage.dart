import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_launcher_icons/main.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigh = MediaQuery.of(context).size.height;
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
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          color: AppColors.primaryColor,
                        ),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                              screenWidth * 0.04,
                              screenHeigh * 0.025,
                              screenWidth * 0.04,
                              screenHeigh * 0.03),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.15),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                          height: screenHeigh * 0.275,
                          child: Column(
                            children: [
                              SizedBox(
                                height: screenHeigh * 0.02,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      right: screenWidth * 0.05),
                                  child: Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Selamat Datang ',
                                              style: TextStyle(
                                                color: AppColors.thirdColor,
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                            Text(
                                              username,
                                              style: TextStyle(
                                                color: AppColors.thirdColor,
                                                fontSize: screenWidth * 0.1,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 4,
                                              color: AppColors.thirdColor,
                                            ),
                                            color: AppColors.secondaryColor,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(image),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeigh * 0.02,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.13,
                                          right: screenWidth * 0.13),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: AppColors.thirdColor
                                              .withOpacity(0.7)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                'Kedudukan',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontSize:
                                                        screenWidth * 0.036,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                currrank.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontFamily: 'Rubik',
                                                    fontSize:
                                                        screenWidth * 0.09,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Text(
                                                'Markah',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontSize:
                                                        screenWidth * 0.036,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    score.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontFamily: 'Rubik',
                                                        fontSize:
                                                            screenWidth * 0.09,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _navigateToFactsView();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: 120,
                                  height: 160,
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
                                  width: 120,
                                  height: 160,
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

                                // Calculate dynamic sizes based on screen width and height
                                double containerWidth =
                                    MediaQuery.of(context).size.width * 0.90;
                                double containerHeight =
                                    MediaQuery.of(context).size.height * 0.25;
                                double padding =
                                    MediaQuery.of(context).size.width * 0.05;

                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      left: padding,
                                      right: padding / 2),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          if (!isUnlock)
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: containerHeight * 0.15),
                                              height: containerHeight,
                                              width: containerWidth,
                                              decoration: BoxDecoration(
                                                color: AppColors.thirdColor
                                                    .withAlpha(200),
                                                border: Border.all(
                                                    width: 10,
                                                    color:
                                                        AppColors.primaryColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.lock_rounded,
                                                      size:
                                                          containerHeight * 0.3,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'Kumpul lebih markah untuk membuka topik ini',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            containerHeight *
                                                                0.10,
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
                                                margin: EdgeInsets.only(
                                                    top:
                                                        containerHeight * 0.15),
                                                height: containerHeight,
                                                width: containerWidth,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        width: 12,
                                                        color: AppColors
                                                            .primaryColor),
                                                    left: BorderSide(
                                                        width: 9,
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 3),
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
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  padding / 2,
                                                              vertical:
                                                                  padding / 4),
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
                                                              Text(
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
                                                                  fontSize:
                                                                      containerHeight *
                                                                          0.15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Container(
                                                                width:
                                                                    containerHeight *
                                                                        0.28,
                                                                height:
                                                                    containerHeight *
                                                                        0.28,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15)),
                                                                  color: AppColors
                                                                      .thirdColor,
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    chapter[
                                                                        'chapter'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Rubik',
                                                                      fontSize:
                                                                          containerHeight *
                                                                              0.2,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            chapter['title'],
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Rubik',
                                                              fontSize:
                                                                  containerHeight *
                                                                      0.13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: AppColors
                                                                  .backgroundColor,
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
                                      SizedBox(width: padding),
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
