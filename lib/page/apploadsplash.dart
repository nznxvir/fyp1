import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp1/Constructor/AuthGate.dart';
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
        backgroundColor: Color(0xFF074173),
        body: const Center(
          child: Image(
            image: AssetImage('assets/hystologo.png'),
          ),
        ),
      ),
    );
  }
}
