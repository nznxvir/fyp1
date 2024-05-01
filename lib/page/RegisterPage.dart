import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/LoginPage.dart';

import '../Constructor/AuthService.dart';
import '../Constructor/appvalidator.dart';

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text != _confirmpasswordController.text) {
        // Show password mismatch error
        AlertDialog(
          title: Text("Password Confirmation Failed"),
          content: Text("The passwords do not match."),
        );
        return; // Do not proceed further
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
        'imageurl':
            'https://firebasestorage.googleapis.com/v0/b/fypquiz-55f06.appspot.com/o/userProfileImages%2Fphoto_2024-04-21_17-07-43.jpg?alt=media&token=25f75f03-58e6-4cb9-afab-d3d944c97960'
      };

      await authService.createUser(data, context, () {
        // Delay navigation to sign-in page by 5 seconds
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
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
        backgroundColor: Color(0xFF074173),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 250,
                    height: 250,
                    child: Image(
                      image: AssetImage('assets/register.png'),
                    ),
                  ),
                  Text(
                    'Daftar Pengguna Baru',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateUserName,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF074173),
                        ),
                        hintText: 'Nama pengguna',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 4, color: Color(0xFFFFC55A)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateAge,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hoverColor: Color(0xFFFFC55A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: Color(0xFF074173),
                          ),
                          hintText: 'Umur',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 4, color: Color(0xFFFFC55A)),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validateEmail,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hoverColor: Color(0xFFFFC55A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xFF074173),
                          ),
                          hintText: 'Email',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 4, color: Color(0xFFFFC55A)),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validatePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hoverColor: Color(0xFFFFC55A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(
                            Icons.password,
                            color: Color(0xFF074173),
                          ),
                          hintText: 'Kata laluan',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 4, color: Color(0xFFFFC55A)),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: _confirmpasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: appValidator.validatePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hoverColor: Color(0xFFFFC55A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(
                            Icons.password,
                            color: Color(0xFF074173),
                          ),
                          hintText: 'Sahkan kata laluan',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 4, color: Color(0xFFFFC55A)),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => SignInPage(),
                          transitionsBuilder: (_, animation, __, child) {
                            return Stack(
                              children: [
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset.zero,
                                    end: Offset(1.0, 0.0),
                                  ).animate(animation),
                                  child: child,
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(-1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child:
                                      SignInPage(), // Replace with your current page content
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Kembali ke log masuk',
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    width: 500,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: isLoader
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_passwordController.text ==
                                    _confirmpasswordController.text) {
                                  _submitForm();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Pengesahan Kata Laluan"),
                                        content:
                                            Text("Kata laluan tidak sepadan"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: isLoader
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              "Daftar",
                              style: TextStyle(
                                  color: Color(0xFF074173),
                                  fontFamily: 'Rubik',
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
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
