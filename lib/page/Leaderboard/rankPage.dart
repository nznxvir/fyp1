import 'package:flutter/material.dart';
import '../homePage.dart';
import '../profilePage.dart';
import 'Leaderboard.dart';

class RankView extends StatelessWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Column(
            children: [
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              height: 65,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF6F131E)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.leaderboard),
                    color: Color(0xFFEEE0C9),
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
                                    end: Offset(-0.5, 0.0),
                                  ).animate(animation),
                                  child: child,
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(0.5, 0.0),
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
                                    end: Offset(-0.5, 0.0),
                                  ).animate(animation),
                                  child: child,
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(0.5, 0.0),
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
          )
        ]),
      ),
    );
  }
}
