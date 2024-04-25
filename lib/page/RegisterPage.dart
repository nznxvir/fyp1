import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  var authService = AuthService();
  var isLoader = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 25),
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
              Text(
                'Create Account',
                style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF5F6F52),
                    fontWeight: FontWeight.bold),
              ),
              Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validateUserName,
                          decoration: InputDecoration(
                              hoverColor: Color(0xFF5F6F52),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFFC6A969),
                              ),
                              hintText: 'Username',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.5, color: Color(0xFF5F6F52)),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validateAge,
                          decoration: InputDecoration(
                              hoverColor: Color(0xFF5F6F52),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Color(0xFFC6A969),
                              ),
                              hintText: 'Age',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.5, color: Color(0xFF5F6F52)),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
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
                          keyboardType: TextInputType.visiblePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: appValidator.validatePassword,
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
                              top: 20, bottom: 10, right: 10, left: 10),
                          child: ElevatedButton(
                              onPressed: () =>
                                  {isLoader ? print("loading") : _submitForm()},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Color(0xFF5F6F52)),
                                minimumSize: MaterialStateProperty.all<Size>(
                                    Size(300, 53)),
                              ),
                              child: isLoader
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ))),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
