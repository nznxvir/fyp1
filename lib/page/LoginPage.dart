import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/RegisterPage.dart';

import 'package:fyp1/page/verifySplash.dart';

import '../Constructor/AuthService.dart';
import '../Constructor/appvalidator.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});

  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // if define here need to add widget

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController; // Define here
  late TextEditingController _passwordController; // Define here

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(); // Initialize here
    _passwordController = TextEditingController(); // Initialize here
  }

  var isLoader = false;
  var authService = AuthService();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      await authService.validateUser(data, context, () {
        // Delay navigation to sign-in page by 5 seconds
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const VerifySplash(),
              transitionsBuilder: (_, animation, __, child) {
                var begin = const Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
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
      // ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
      //     const SnackBar(content: Text("Form Submitted succesfully")));
    }
  }

  var appValidator = AppValidator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Image(
                    alignment: Alignment.center,
                    image: AssetImage('assets/login.jpg'),
                    width: 400,
                    height: 400,
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
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: appValidator.validateEmail,
                            decoration: InputDecoration(
                                hoverColor: const Color(0xFF074173),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Color(0xFF074173),
                                ),
                                hintText: 'Email',
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      width: 4,
                                      color: Color(0xFF074173),
                                    ),
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: TextFormField(
                            controller: _passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: appValidator.validatePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                                hoverColor: const Color(0xFF074173),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(
                                  Icons.password,
                                  color: Color(0xFF074173),
                                ),
                                hintText: 'Password',
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      width: 4,
                                      color: Color(0xFF074173),
                                    ),
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 500,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: () {
                              isLoader ? print("loading") : _submitForm();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF074173),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: isLoader
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : const Text(
                                    "Log Masuk",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        const Center(
                          child: Text(
                            "Atau",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Rubik'),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          width: 500,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  pageBuilder: (_, __, ___) =>
                                      const RegisterPage(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                    return Stack(
                                      children: [
                                        SlideTransition(
                                          position: Tween<Offset>(
                                            begin: Offset.zero,
                                            end: const Offset(-0.5, 0.0),
                                          ).animate(animation),
                                          child: child,
                                        ),
                                        SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.5, 0.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child:
                                              const RegisterPage(), // Replace with your current page content
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF074173),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            child: const Text(
                              "Daftar Pengguna",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
