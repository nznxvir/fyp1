import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'RankTile.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final leaderboard = snapshot.data!.docs;
        final user = FirebaseAuth.instance.currentUser;

        // Update all user ranks
        for (int i = 0; i < leaderboard.length; i++) {
          final userId = leaderboard[i].id;
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'rank': i + 1,
          });
        }

        // Find user's rank
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
