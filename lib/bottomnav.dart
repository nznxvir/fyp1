import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.leaderboard),
            color: widget.currentIndex == 0
                ? AppColors.thirdColor
                : AppColors.backgroundColor,
            iconSize: 35,
            onPressed: () => widget.onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.home_filled),
            color: widget.currentIndex == 1
                ? AppColors.thirdColor
                : AppColors.backgroundColor,
            iconSize: 35,
            onPressed: () => widget.onTap(1),
          ),
          IconButton(
            icon: Icon(Icons.person),
            color: widget.currentIndex == 2
                ? AppColors.thirdColor
                : AppColors.backgroundColor,
            iconSize: 35,
            onPressed: () => widget.onTap(2),
          ),
        ],
      ),
    );
  }
}
