import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('history')
              .where('userId', isEqualTo: userId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        // Clear the existing list before adding new items
        _historyList.clear();

        // Add data from all documents to the list
        for (var doc in snapshot.docs) {
          var historyData = doc.data();
          _historyList.add({
            'chapter': historyData['chapter'],
            'correctCount': historyData['correctCount'],
            'currentDate': historyData['currentDate'],
            'currentTime': historyData['currentTime'],
            'score': historyData['score'],
            'setnum': historyData['setnum'],
            'timeSpent': historyData['timeSpent'],
            'username': historyData['username'],
            'unansweredCount': historyData['unansweredCount'],
            'wrongCount': historyData['wrongCount'],
          });
        }
        // Update the state to reflect the changes
        setState(() {});
      } else {
        // Handle the case where no history data exists for the user
        print('No history data found for user $userId');
      }
    } catch (error) {
      // Handle any errors that occur during fetching data
      print('Error fetching history data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  color: Colors.amber[200]),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 300,
                    child: Text(
                      'Rekod ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5F6F52)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 25,
                ),
                Text(
                  'Log Permainan',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset: Offset(
                              0, 3), // Offset in the positive direction (down)
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarikh: ${_historyList[index]['currentDate']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Masa: ${_historyList[index]['currentTime']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Bab: ${_historyList[index]['chapter']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Modul: ${_historyList[index]['setnum']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Jumlah Betul: ${_historyList[index]['correctCount']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Jumlah Salah: ${_historyList[index]['wrongCount']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Soalan Tidak Dijawab: ${_historyList[index]['unansweredCount']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Masa Diambil: ${_historyList[index]['timeSpent']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Markah: ${_historyList[index]['score']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
