import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/LoginPage.dart';

import '../alertBox.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ResetPasswordPage({Key? key}) : super(key: key);

  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      player.play(AssetSource('audio/pop.mp3'));
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                    icon: Icon(Icons.cancel_rounded),
                    iconSize: 50,
                    color: AppColors.secondaryColor,
                    alignment: Alignment.topRight,
                  ),
                ],
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/forgot.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Set semula kata laluan',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Masukkan email untuk menukar kata laluan baharu',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 4, color: AppColors.secondaryColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          resetPassword(emailController.text.trim(), context);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            width: 300,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.secondaryColor),
                            child: Text(
                              'Hantar email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.backgroundColor),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetPassword(String email, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        throw 'Invalid email format';
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      showSuccessMessage(
        context,
        "Email telah dihantar",
      );
    } catch (e) {
      Navigator.pop(context);

      final errorMessage = e is FirebaseAuthException
          ? e.message ?? "Email gagal dihantar. Sila cuba lagi"
          : "Email gagal dihantar. Sila cuba lagi";

      showErrorMessage(context, errorMessage);
    }
  }

  void showSuccessMessage(BuildContext context, String message) {
    showAutoDismissAlertDialog(
        context,
        'Email berjaya dihantar. Periksa email untuk menukar kata laluan',
        'assets/success.png');
  }

  void showErrorMessage(BuildContext context, String message) {
    showAutoDismissAlertDialog(
        context, 'Email gagal dihantar. Sila cuba lagi', 'assets/failed.png');
  }
}
