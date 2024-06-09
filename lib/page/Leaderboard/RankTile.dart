import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';

class RankTile extends StatelessWidget {
  final String username;
  final String image;
  final int score;
  final int rank;
  final int? userRank;

  const RankTile({
    Key? key,
    required this.username,
    required this.image,
    required this.score,
    required this.rank,
    this.userRank,
  }) : super(key: key);

  Color _getBorderColor(int rank) {
    switch (rank) {
      case 1:
        return Color.fromARGB(255, 233, 195, 71);
      case 2:
        return Color.fromARGB(255, 113, 113, 113);
      case 3:
        return Color.fromARGB(255, 227, 132, 36);
      default:
        return AppColors.backgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBorderColor(rank);

    return Container(
      width: 150,
      height: 115,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        border: Border(
            bottom: BorderSide(
                width: 5, color: AppColors.secondaryColor.withOpacity(0.2)),
            left: BorderSide(
                width: 3, color: AppColors.secondaryColor.withOpacity(0.2))),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            bgColor,
            bgColor.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Posisi ${rank == userRank ? userRank : rank}',
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                fontFamily: 'Rubik'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryColor,
                        image: DecorationImage(
                            fit: BoxFit.cover, image: NetworkImage(image))),
                  ),
                  SizedBox(width: 15),
                  Text(username,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubik',
                          color: AppColors.primaryColor))
                ],
              ),
              Text(score.toString(),
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rubik',
                      color: AppColors.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}
