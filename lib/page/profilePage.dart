import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/page/historyPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'homePage.dart';
import 'rankPage.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password changed successfully"),
        ));

        setState(() {
          password = newPassword;
        });
      }
    } catch (error) {
      print("Error changing password: $error");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                  padding: EdgeInsets.only(top: 10),
                  width: double.infinity,
                  height: 330,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50)),
                    color: Color(0xFF074173),
                  ),
                  child: Column(
                    children: [
                      Stack(children: [
                        Container(
                          decoration: BoxDecoration(
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
                                : Image(
                                    image: AssetImage('assets/rentap.png'),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFC55A)),
                            child: IconButton(
                              icon: Icon(Icons.edit),
                              color: Color(0xFF074173),
                              onPressed: () {
                                _getImage();
                              },
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: 350,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              )
                            ],
                            color: Colors.white),
                        child: Text(
                          username,
                          style: TextStyle(
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
                  margin: EdgeInsets.fromLTRB(30, 240, 30, 50),
                  width: 400,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 120,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tukar nama',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Color(0xFFFFC55A),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tukar kata laluan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: Icon(Icons.password_rounded),
                              color: Color(0xFFFFC55A),
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
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Set semula markah',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF074173))),
                            IconButton(
                              icon: Icon(Icons.refresh),
                              color: Color(0xFFFFC55A),
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
                margin: EdgeInsets.only(right: 30, left: 30),
                padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Maklumat Pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nama',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(username,
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(email,
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Umur',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(age,
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Skor',
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(score.toString(),
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey))
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xFF074173)),
                    child: Text(
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
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF074173)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.leaderboard),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => RankView(),
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
                                  RankView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.home_filled),
                color: Colors.white,
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => HomeView(),
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
                                  HomeView(), // Replace with your current page content
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFFFFC55A),
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
      backgroundColor: Color(0xFF5F6F52),
      shape: RoundedRectangleBorder(
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
                padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    Text(
                      'Change Username',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC6A969),
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
                            borderSide: BorderSide(
                              color: Color(0xFFC6A969),
                              width: 3,
                            ),
                          ),
                          hintText: 'New username',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Color.fromRGBO(198, 169, 105, 1),
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
                                  Size(130, 60)),
                            ),
                            child: Text(
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
                                  Color(0xFFC6A969)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(130, 60)),
                            ),
                            child: Text(
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
      backgroundColor: Color(0xFF5F6F52),
      shape: RoundedRectangleBorder(
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
                padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC6A969),
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
                            borderSide: BorderSide(
                              color: Color(0xFFC6A969),
                              width: 3,
                            ),
                          ),
                          hintText: 'New password',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Color.fromRGBO(198, 169, 105, 1),
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
                                  Size(130, 60)),
                            ),
                            child: Text(
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
                                  Color(0xFFC6A969)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(130, 60)),
                            ),
                            child: Text(
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
      backgroundColor: Color(0xFF5F6F52),
      shape: RoundedRectangleBorder(
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
                padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    Text(
                      'Reset Score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC6A969),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
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
                                  Size(130, 60)),
                            ),
                            child: Text(
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
                                  Color(0xFFC6A969)),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(130, 60)),
                            ),
                            child: Text(
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
