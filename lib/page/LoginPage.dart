import 'package:flutter/material.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/RegisterPage.dart';
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
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
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
                    image: AssetImage('assets/history.png'),
                    width: 300,
                    height: 300,
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
                          validator: appValidator.validatePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                              hoverColor: const Color(0xFF074173),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: const Icon(
                                Icons.password,
                                color: AppColors.secondaryColor,
                              ),
                              hintText: 'Password',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 4,
                                    color: AppColors.secondaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                        height: 25,
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
                        height: 25,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 350,
                            height: 65,
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Text(
                              "Daftar Pengguna",
                              style: TextStyle(
                                  fontFamily: 'Rubik',
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
