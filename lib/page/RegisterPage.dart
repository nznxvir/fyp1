import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/LoginPage.dart';
import 'package:fyp1/page/homePage.dart';
import 'package:fyp1/page/verifySplash.dart';

import '../Constructor/AuthService.dart';
import '../Constructor/appvalidator.dart';
import '../alertBox.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;
  bool _isPasswordVisible = false;
  bool _isCPasswordVisible = false;
  final player = AudioPlayer();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text != _confirmpasswordController.text) {
        // Show password mismatch error

        showAutoDismissAlertDialog(
            context, 'Kata laluan tidak sepadan', 'assets/failed.png');

        return;
      }
      setState(() {
        isLoader = true;
      });

      var data = {
        "username": _usernameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "age": _ageController.text,
        "score": 0,
        "rank": 0,
        'imageurl':
            'https://firebasestorage.googleapis.com/v0/b/fypquiz-55f06.appspot.com/o/userProfileImages%2Fphoto_2024-04-21_17-07-43.jpg?alt=media&token=25f75f03-58e6-4cb9-afab-d3d944c97960'
      };

      await authService.createUser(data, context, () {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const HomeView(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      });

      setState(() {
        isLoader = false;
      });
    }
  }

  var appValidator = AppValidator();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    child: const Image(
                      image: AssetImage('assets/reg.png'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Daftar Pengguna Baru',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateUserName,
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: AppColors.secondaryColor,
                        ),
                        hintText: 'Nama pengguna',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 4, color: AppColors.secondaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateAge,
                      decoration: InputDecoration(
                          fillColor: AppColors.backgroundColor,
                          filled: true,
                          hoverColor: AppColors.secondaryColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(
                            Icons.numbers,
                            color: AppColors.secondaryColor,
                          ),
                          hintText: 'Umur',
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 4, color: AppColors.secondaryColor),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateEmail,
                      decoration: InputDecoration(
                          fillColor: AppColors.backgroundColor,
                          filled: true,
                          hoverColor: AppColors.secondaryColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: AppColors.secondaryColor,
                          ),
                          hintText: 'Email',
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 4, color: AppColors.secondaryColor),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validatePassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundColor,
                        filled: true,
                        hoverColor: AppColors.secondaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.password,
                          color: AppColors.secondaryColor,
                        ),
                        hintText: 'Kata laluan',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 4,
                            color: AppColors.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.secondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _confirmpasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validatePassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundColor,
                        filled: true,
                        hoverColor: AppColors.secondaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.password,
                          color: AppColors.secondaryColor,
                        ),
                        hintText: 'Kata laluan',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 4,
                            color: AppColors.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.secondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCPasswordVisible = !_isCPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => SignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Kembali ke log masuk',
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: isLoader
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_passwordController.text ==
                                    _confirmpasswordController.text) {
                                  player.play(AssetSource('audio/logout.mp3'));
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    _submitForm();
                                  });
                                } else {
                                  player.play(AssetSource('audio/wrong.mp3'));
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    showAutoDismissAlertDialog(
                                        context,
                                        'Kata laluan tidak sepadan',
                                        'assets/failed.png');
                                  });
                                }
                              }
                            },
                      child: Container(
                        alignment: Alignment.center,
                        width: 350,
                        height: 65,
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    width: 6, color: AppColors.primaryColor),
                                bottom: BorderSide(
                                    width: 10, color: AppColors.primaryColor)),
                            color: AppColors.secondaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: isLoader
                            ? const Center(child: CircularProgressIndicator())
                            : const Text(
                                "Daftar",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.backgroundColor,
                                    fontSize: 20),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
