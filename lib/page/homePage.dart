import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:fyp1/page/historyPage.dart';
import 'package:fyp1/page/profilePage.dart';
import 'package:fyp1/page/Leaderboard/rankPage.dart';
import 'package:fyp1/page/setListPage.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

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

  @override
  void initState() {
    super.initState();
    getUserData();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                  height: 270,
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
                      bottom: 20,
                      right: 20,
                      left: 20,
                      top:
                          170), // Adjust top margin to position the white container inside the blue container
                  decoration: BoxDecoration(
                    border: Border.all(width: 10, color: Color(0xFFEEE0C9)),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              'Ranking',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const Text(
                              'Markah',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
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
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HistoryView(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return Stack(
                            children: [
                              SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset.zero,
                                    end: const Offset(0, -1),
                                  ).animate(animation),
                                  child: const HomeView()),
                              SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.5),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: const HistoryView()),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F131E),
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
                color:
                    Colors.white, // Set the default background color to white
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
                        DocumentSnapshot chapter = snapshot.data!.docs[index];
                        bool isUnlock = chapter['isUnlock'];
                        String imageUrl = chapter[
                            'imageurl']; // Get the image URL from the database
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: isUnlock
                                    ? () {
                                        _chapterDescribe(context, chapter);
                                      }
                                    : null,
                                child: Container(
                                  height: 170,
                                  width: 370,
                                  decoration: BoxDecoration(
                                    color: isUnlock
                                        ? Colors.transparent
                                        : Colors.black.withOpacity(0.8),
                                    border: Border.all(
                                        width: 10,
                                        color: const Color(0xFF6F131E)),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isUnlock
                                            ? Colors.grey.withOpacity(0.8)
                                            : Colors.transparent,
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                    // Set the background image using the image URL
                                    image: isUnlock
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 10,
                                            top: 5,
                                            bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Bab',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: 'Rubik',
                                                    color: Colors.white,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
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
                                                    color: Color(0xFF6F131E),
                                                  ),
                                                  child: Text(
                                                    chapter['chapter'],
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily: 'Rubik',
                                                      fontSize: 42,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFEEE0C9),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              chapter['title'],
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isUnlock)
                                        const Text(
                                          'Tambah untuk membuka bab ini',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF6F131E)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.leaderboard),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => const RankView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(0.5, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.5, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  const RankView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_filled),
                color: const Color(0xFFEEE0C9),
                iconSize: 35,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => const ProfileView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(-0.5, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.5, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  const ProfileView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _chapterDescribe(BuildContext context, DocumentSnapshot chapter) {
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
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                SetListView(chapterId: chapter.id),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return Stack(
                                children: [
                                  SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset.zero,
                                        end: const Offset(0, -1),
                                      ).animate(animation),
                                      child: const HomeView()),
                                  SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.5),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child:
                                          SetListView(chapterId: chapter.id)),
                                ],
                              );
                            },
                          ),
                        );
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
}
