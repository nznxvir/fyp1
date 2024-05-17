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
        return Color(0xFFd4af37);
      case 2:
        return Color(0xffC0C0C0);
      case 3:
        return Color.fromARGB(255, 182, 113, 44);
      default:
        return AppColors.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(rank);

    return Container(
      width: 150,
      height: 120,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: AppColors.backgroundColor,
        border: Border.all(color: borderColor, width: 5),
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
            'Rank ${rank == userRank ? userRank : rank}',
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: borderColor,
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
                          fontSize: 22,
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
