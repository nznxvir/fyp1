import 'package:cloud_firestore/cloud_firestore.dart';

// Function to update ranks of users based on their scores
Future<void> updateRank() async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final leaderboardSnapshot =
      await usersCollection.orderBy('score', descending: true).get();

  final leaderboard = leaderboardSnapshot.docs;
  for (int i = 0; i < leaderboard.length; i++) {
    final userId = leaderboard[i].id;
    await usersCollection.doc(userId).update({
      'rank': i + 1,
    });
  }
}
