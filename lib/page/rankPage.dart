import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homePage.dart';
import 'profilePage.dart';

class RankView extends StatelessWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 77,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: Colors.white,
            ),
            child: Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5F6F52),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              width: double.infinity,
              color: Colors.white,
              child: Leaderboard(key: UniqueKey()),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 12),
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF5F6F52),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.leaderboard),
                  color: Color(0xFFC6A969),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RankView()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.home_filled),
                  color: Colors.white,
                  iconSize: 35,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView()),
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
                      MaterialPageRoute(builder: (context) => ProfileView()),
                    );
                  },
                ),
              ],
            ),
          )
        ],
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
            final score = leaderboard[index]['score'] as int;
            return RankTile(
              username: username,
              score: score,
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
  final int score;
  final int rank;
  final int? userRank;

  const RankTile({
    Key? key,
    required this.username,
    required this.score,
    required this.rank,
    this.userRank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 110,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(username,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF5F6F52))),
              Text(score.toString(),
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF5F6F52))),
            ],
          ),
        ],
      ),
    );
  }
}
