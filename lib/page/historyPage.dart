import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late List<Map<String, dynamic>> _historyList = [];
  final player = AudioPlayer();

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
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.04,
                right: MediaQuery.of(context).size.width * 0.04,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.1,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                  color: AppColors.secondaryColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: AppColors.thirdColor,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      player.play(AssetSource('audio/pop.mp3'));
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                      ),
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: AppColors.secondaryColor,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: MediaQuery.of(context).size.width * 0.05,
                        color: AppColors.thirdColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                    ),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      'Rekod pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.05,
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.03,
                      horizontal: MediaQuery.of(context).size.width * 0.055,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 11,
                          color: AppColors.secondaryColor,
                        ),
                        left: BorderSide(
                          width: 8,
                          color: AppColors.secondaryColor,
                        ),
                      ),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _historyList[index]['currentDate'],
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _historyList[index]['currentTime'],
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Topik',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.secondaryColor,
                                  ),
                                  child: Text(
                                    _historyList[index]['chapter'],
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: AppColors.thirdColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.025,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Modul',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.secondaryColor,
                                  ),
                                  child: Text(
                                    _historyList[index]['setnum'],
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: AppColors.thirdColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Betul',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  height:
                                      MediaQuery.of(context).size.width * 0.13,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 5,
                                        color: AppColors.primaryColor,
                                      ),
                                      left: BorderSide(
                                        width: 3,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                  ),
                                  child: Text(
                                    _historyList[index]['correctCount']
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Tidak dijawab',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  height:
                                      MediaQuery.of(context).size.width * 0.13,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 5,
                                        color: AppColors.primaryColor,
                                      ),
                                      left: BorderSide(
                                        width: 3,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.thirdColor,
                                  ),
                                  child: Text(
                                    _historyList[index]['unansweredCount']
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Salah',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  height:
                                      MediaQuery.of(context).size.width * 0.13,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 5,
                                        color: AppColors.primaryColor,
                                      ),
                                      left: BorderSide(
                                        width: 3,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.redAccent,
                                  ),
                                  child: Text(
                                    _historyList[index]['wrongCount']
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: AppColors.secondaryColor,
                              ),
                              child: Text(
                                'Masa Diambil: ${_historyList[index]['timeSpent']}',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.thirdColor,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: AppColors.secondaryColor,
                              ),
                              child: Text(
                                'Markah: ${_historyList[index]['score']}',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.thirdColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
