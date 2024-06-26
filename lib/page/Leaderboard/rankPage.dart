import 'package:flutter/material.dart';
import 'package:fyp1/bottomnav.dart';
import 'package:fyp1/page/Colors.dart';
import '../homePage.dart';
import '../profilePage.dart';
import 'Leaderboard.dart';

class RankView extends StatefulWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> {
  @override
  Widget build(BuildContext context) {
    void _onTap(int index) {
      setState(() {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
            break;
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 65),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    width: double.infinity,
                    height: 740,
                    color: AppColors.backgroundColor,
                    child: Leaderboard(key: UniqueKey()),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 35,
              left: 35,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  'Kedudukan Semasa',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                    color: AppColors.thirdColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
