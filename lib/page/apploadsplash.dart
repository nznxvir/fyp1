import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp1/Constructor/AuthGate.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Get.to(AuthGate());
    });
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: const Center(
          child: Image(
            image: AssetImage('assets/hystologo.png'),
          ),
        ),
      ),
    );
  }
}
