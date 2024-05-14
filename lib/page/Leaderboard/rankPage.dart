import 'package:flutter/material.dart';
import 'package:fyp1/bottomnav.dart';
import '../homePage.dart';
import '../profilePage.dart';
import 'Leaderboard.dart';

class RankView extends StatefulWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    void _onTap(int index) {
      setState(() {
        _currentIndex = index;
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 65),
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
            Positioned(
              top: 0,
              right: 40,
              left: 40,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Color(0xFF6F131E),
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
            ),
          ],
        ),
      ),
    );
  }
}
