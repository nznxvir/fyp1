import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/historyPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'Leaderboard/rankPage.dart';
import 'homePage.dart';
import 'LoginPage.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final user = FirebaseAuth.instance.currentUser!;
  late String username = '';
  late String age = '';
  late String email = '';
  late int score = 0;
  late String password;
  String? imageurl;
  File? _image;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      username = userDoc['username'];
      age = userDoc['age'];
      imageurl = userDoc['imageurl'];
      score = userDoc['score'];
      email = userDoc['email'];
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
      (route) => false,
    );
  }

  Future<void> changeUsername(String newUsername) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(newUsername);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});
      setState(() {
        username = newUsername;
      });
    }
  }

  Future<void> changePassword(String newPassword) async {
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        // Update password in FirebaseAuth
        await user.updatePassword(newPassword);

        // Update password in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'password': newPassword});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Password changed successfully"),
        ));

        setState(() {
          password = newPassword;
        });
      }
    } catch (error) {
      print("Error changing password: $error");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to change password. Please try again."),
      ));
    }
  }

  Future<void> resetScore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'score': 0});
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImageToFirebase(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImageToFirebase(BuildContext context) async {
    if (_image != null) {
      try {
        // Upload image to Firebase Storage
        final firebase_storage.Reference firebaseStorageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('userProfileImages/${user.uid}/profilePic.jpg');

        await firebaseStorageRef.putFile(_image!);

        // Get the URL of the uploaded image
        final String downloadURL = await firebaseStorageRef.getDownloadURL();

        // Save the image URL in the Firestore user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'imageurl': downloadURL});

        setState(() {
          imageurl = downloadURL;
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to upload image. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  height: 330,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50)),
                    color: Color(0xFF074173),
                  ),
                  child: Column(
                    children: [
                      Stack(children: [
                        Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.white),
                          width: 120,
                          height: 120,
                          child: ClipOval(
                            child: imageurl != null
                                ? Image.network(
                                    imageurl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Image(
                                    image: AssetImage('assets/rentap.png'),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEEE0C9)),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xFF074173),
                              onPressed: () {
                                _getImage();
                              },
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: 350,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              )
                            ],
                            color: Colors.white),
                        child: Text(
                          username,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Rubik',
                              color: Color(0xFF074173)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 240, 30, 50),
                  width: 400,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 120,
                        height: 130,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Tukar nama',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xFFEEE0C9),
                              iconSize: 40,
                              onPressed: () {
                                _changeName(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 130,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Tukar kata laluan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: const Icon(Icons.password_rounded),
                              color: const Color(0xFFEEE0C9),
                              iconSize: 40,
                              onPressed: () {
                                _ChangePassword(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 130,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Set semula markah',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              color: const Color(0xFFEEE0C9),
                              iconSize: 40,
                              onPressed: () {
                                _ResetScore(context);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ]),
              Container(
                margin: const EdgeInsets.only(right: 30, left: 30),
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Maklumat Pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nama',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(username,
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(email,
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Umur',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(age,
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Skor',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(score.toString(),
                            style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                  onTap: () {
                    logout();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 280,
                    height: 60,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xFF074173)),
                    child: const Text(
                      'Log Keluar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  )),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF074173)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.leaderboard),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => const RankView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(0.5, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.5, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  const RankView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_filled),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => const HomeView(),
                      transitionsBuilder: (_, animation, __, child) {
                        return Stack(
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(0.5, 0.0),
                              ).animate(animation),
                              child: child,
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.5, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child:
                                  const HomeView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: const Color(0xFFEEE0C9),
                iconSize: 35,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeName(BuildContext context) {
    TextEditingController newUsernameController = TextEditingController();
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xFF5F6F52),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 300,
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    const Text(
                      'Change Username',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEEE0C9),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 20, left: 20),
                      child: TextField(
                        controller: newUsernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFEEE0C9),
                              width: 3,
                            ),
                          ),
                          hintText: 'New username',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEE0C9),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              changeUsername(newUsernameController.text);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFFEEE0C9)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _ChangePassword(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xFF5F6F52),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 300,
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEEE0C9),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 20, left: 20),
                      child: TextField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFEEE0C9),
                              width: 3,
                            ),
                          ),
                          hintText: 'New password',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEE0C9),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              changePassword(newPasswordController.text);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFFEEE0C9)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _ResetScore(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color(0xFF5F6F52),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 200,
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    const Text(
                      'Reset Score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEEE0C9),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Are you sure you want to reset your score?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              resetScore();
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFFEEE0C9)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(130, 60)),
                            ),
                            child: const Text(
                              'Reset',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
