import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/homePage.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class VerifySplash extends StatefulWidget {
  const VerifySplash({super.key});

  @override
  State<VerifySplash> createState() => _VerifySplashState();
}

class _VerifySplashState extends State<VerifySplash> {
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 5), () {
      Get.to(HomeView());
    });
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Center(
        child: Lottie.asset(
          'assets/animation/test.json',
        ),
      ),
    );
  }
}
