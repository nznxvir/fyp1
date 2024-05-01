import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homePage.dart';
import 'profilePage.dart';

class RankView extends StatelessWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: 300,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: Color(0xFF074173),
              ),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                height: 740,
                color: Colors.white,
                child: Leaderboard(key: UniqueKey()),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF074173)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.leaderboard),
                color: Color(0xFFFFC55A),
                iconSize: 35,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.home_filled),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => HomeView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: Offset(-1, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  HomeView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => ProfileView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: Offset(-1, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  ProfileView(), // Replace with your current page content
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
}

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final leaderboard = snapshot.data!.docs;
        final user = FirebaseAuth.instance.currentUser;
        int? userRank;
        for (var i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i].id == user!.uid) {
            userRank = i + 1;
            break;
          }
        }
        return ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final username = leaderboard[index]['username'];
            final image = leaderboard[index]['imageurl'];
            final score = leaderboard[index]['score'] as int;
            return RankTile(
              username: username,
              score: score,
              image: image,
              rank: index + 1,
              userRank: userRank,
            );
          },
        );
      },
    );
  }
}

class RankTile extends StatelessWidget {
  final String username;
  final String image;
  final int score;
  final int rank;
  final int? userRank;

  const RankTile({
    Key? key,
    required this.username,
    required this.image,
    required this.score,
    required this.rank,
    this.userRank,
  }) : super(key: key);

  Color _getBorderColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFd4af37); // Gold color for the first rank
      case 2:
        return Color(0xffC0C0C0); // Silver color for the second rank
      case 3:
        return Color.fromARGB(
            255, 182, 113, 44); // Bronze color for the third rank
      default:
        return Colors.transparent; // Transparent for other ranks
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(rank);

    return Container(
      width: 150,
      height: 120,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        border: Border.all(color: borderColor, width: 5), // Set border color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Rank ${rank == userRank ? userRank : rank}',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(width: 5, color: Color(0xFFFFC55A)),
                        shape: BoxShape.circle,
                        color: Color(0xFFFFC55A),
                        image: DecorationImage(
                            fit: BoxFit.cover, image: NetworkImage(image))),
                  ),
                  SizedBox(width: 15),
                  Text(username,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubik',
                          color: Color(0xFF5F6F52)))
                ],
              ),
              Text(score.toString(),
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rubik',
                      color: Color(0xFF5F6F52))),
            ],
          ),
        ],
      ),
    );
  }
}
