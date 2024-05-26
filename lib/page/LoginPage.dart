import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/RegisterPage.dart';
import 'package:fyp1/page/resetPassword.dart';
import 'package:fyp1/page/verifySplash.dart';
import '../Constructor/AuthService.dart';
import '../Constructor/appvalidator.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  var isLoader = false;
  var authService = AuthService();

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      await authService.validateUser(data, context, () {
        player.play(AssetSource('audio/intro.mp3'));
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1000),
              pageBuilder: (_, __, ___) => const VerifySplash(),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Image(
                    alignment: Alignment.center,
                    image: AssetImage('assets/tar.png'),
                    width: 250,
                    height: 250,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Kembali',
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validateEmail,
                          decoration: InputDecoration(
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
                                    width: 4,
                                    color: AppColors.secondaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator
                              .validatePassword, // Ensure this validator is defined in your code
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hoverColor: const Color(0xFF074173),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.password,
                              color: AppColors
                                  .secondaryColor, // Ensure AppColors is defined in your code
                            ),
                            hintText: 'Password',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 4,
                                color: AppColors
                                    .secondaryColor, // Ensure AppColors is defined in your code
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors
                                    .secondaryColor, // Ensure AppColors is defined in your code
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
                      Container(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            onTap: () {
                              player.play(AssetSource('audio/button.mp3'));
                              Future.delayed(Duration(milliseconds: 500), () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 500),
                                    pageBuilder: (_, __, ___) =>
                                        ResetPasswordPage(),
                                    transitionsBuilder: (_, animation,
                                        secondaryAnimation, child) {
                                      var begin = Offset(
                                          1.0, 0.0); // Start from right to left
                                      var end = Offset.zero;
                                      var curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              });
                            },
                            child: Text(
                              'Terlupa kata laluan',
                              style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            isLoader ? print("loading") : _submitForm(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 350,
                            height: 65,
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        width: 6,
                                        color: AppColors.primaryColor),
                                    bottom: BorderSide(
                                        width: 10,
                                        color: AppColors.primaryColor)),
                                color: AppColors.secondaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: isLoader
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : const Text(
                                    "Log Masuk",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.backgroundColor,
                                        fontSize: 20),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Center(
                        child: Text(
                          "Atau",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Rubik'),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            player.play(AssetSource('audio/button.mp3'));
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => RegisterPage(),
                                ),
                              );
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 350,
                            height: 65,
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border(
                                    left: BorderSide(
                                        width: 6,
                                        color: AppColors.primaryColor),
                                    bottom: BorderSide(
                                        width: 10,
                                        color: AppColors.primaryColor)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Text(
                              "Daftar pengguna",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
