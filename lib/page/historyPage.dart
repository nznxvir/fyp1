import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';

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
        backgroundColor: AppColors.backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
              width: double.infinity,
              height: 80,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  border: Border.all(width: 4, color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: AppColors.thirdColor),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors.secondaryColor,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          weight: 5,
                          color: AppColors.thirdColor,
                        )),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    alignment: Alignment.center,
                    height: 90,
                    width: 200,
                    child: const Text(
                      'Rekod pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Permainan',
                    style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w800,
                        fontSize: 25),
                  ),
                  Text(
                    'User',
                    style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor),
                  ),
                ],
              ),
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
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 10, color: AppColors.secondaryColor),
                          left: BorderSide(
                              width: 7, color: AppColors.secondaryColor)),
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
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
