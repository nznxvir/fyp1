import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/RegisterPage.dart';
import 'package:fyp1/page/homePage.dart';

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
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeView()),
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
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                margin: EdgeInsets.only(bottom: 30),
                decoration: const BoxDecoration(
                    color: Color(0xFF5F6F52),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                alignment: Alignment.center,
                height: 250,
                width: double.infinity,
                child: const Image(
                  image: AssetImage('assets/hysto_logo.png'),
                ),
              ),
              const Text(
                'Welcome Back',
                style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFF5F6F52),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validateEmail,
                          decoration: InputDecoration(
                              hoverColor: Color(0xFF5F6F52),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFFC6A969),
                              ),
                              hintText: 'Email',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.5, color: Color(0xFF5F6F52)),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validatePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                              hoverColor: Color(0xFF5F6F52),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Color(0xFFC6A969),
                              ),
                              hintText: 'Password',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.5, color: Color(0xFF5F6F52)),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, bottom: 10, right: 70, left: 70),
                        child: ElevatedButton(
                          onPressed: () {
                            isLoader ? print("loading") : _submitForm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .black, // Sets the background color to black
                          ),
                          child: isLoader
                              ? const Center(child: CircularProgressIndicator())
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Sets the text color to white
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, right: 40, left: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Dont have acconut yet?',
                              style: TextStyle(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterPage()),
                                );
                              },
                              child: Text('Create account',
                                  style: TextStyle(
                                      color: Color(0xFF5F6F52),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      )
                    ],
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
