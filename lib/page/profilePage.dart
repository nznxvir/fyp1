import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp1/page/Colors.dart';
import 'package:fyp1/page/rankUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../alertBox.dart';
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
  late String pass = '';
  String? imageurl;
  File? _image;
  bool _isConfirming = false;
  final player = AudioPlayer();

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
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = const Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> changeUsername(String newUsername) async {
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        await user.updateDisplayName(newUsername);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': newUsername});
        setState(() {
          username = newUsername;
        });
        showAutoDismissAlertDialog(
            context, 'Proses berjaya', 'assets/success.png');
      }
    } catch (error) {
      print("Error changing password: $error");

      showAutoDismissAlertDialog(
          context, 'Proses gagal. Sila cuba lagi', 'assets/failed.png');
    }
  }

  Future<void> changePassword(String newPassword) async {
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        print(user);
        // Update password in FirebaseAuth
        await user.updatePassword(newPassword);

        // Show success message
        showAutoDismissAlertDialog(
            context, 'Proses berjaya', 'assets/success.png');

        // Update local password variable
        setState(() {
          password = newPassword;
        });
      }
    } catch (error) {
      print("Error changing password: $error");

      showAutoDismissAlertDialog(context,
          'Gagal menukar kata laluan. Sila cuba lagi', 'assets/failed.png');
    }
  }

  Future<void> resetScore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'score': 0});
    Navigator.pop(context);

    Future.delayed(Duration(seconds: 2), () {
      showAutoDismissAlertDialog(
          context, 'Proses berjaya', 'assets/success.png');
    });
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
        showAutoDismissAlertDialog(context,
            'Gagal memuat naik gambar. Sila cuba lagi', 'assets/failed.png');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onTap(int index) {
      setState(() {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RankView()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
            );
            break;
          case 2:
            break;
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: AppColors.primaryColor,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: AppColors.backgroundColor,
                              ),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              child: ClipOval(
                                child: imageurl != null
                                    ? Image.network(
                                        imageurl!,
                                        fit: BoxFit.cover,
                                      )
                                    : CircularProgressIndicator(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.thirdColor,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  color: AppColors.primaryColor,
                                  onPressed: () {
                                    _getImage();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.045,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: AppColors.backgroundColor,
                          ),
                          child: Text(
                            username,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.075,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Rubik',
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                        30,
                        MediaQuery.of(context).size.height * 0.24,
                        30,
                        30,
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: AppColors.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildOptionContainer(
                            context,
                            'Tukar nama',
                            Icons.edit,
                            () {
                              _changeName(context);
                            },
                          ),
                          buildOptionContainer(
                            context,
                            'Tukar kata laluan',
                            Icons.password_rounded,
                            () {
                              _ChangePassword(context);
                            },
                          ),
                          buildOptionContainer(
                            context,
                            'Set semula markah',
                            Icons.refresh,
                            () {
                              _ResetScore(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 35),
                padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  border: Border.all(width: 7, color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Maklumat Pengguna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    buildInfoRow(context, 'Nama', username),
                    buildInfoRow(context, 'Email', email),
                    buildInfoRow(context, 'Umur', age),
                    buildInfoRow(context, 'Skor', score.toString()),
                  ],
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  player.play(AssetSource('audio/logout.mp3'));
                  Future.delayed(Duration(milliseconds: 500), () {
                    logout();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 8,
                        color: AppColors.primaryColor,
                      ),
                      left: BorderSide(
                        width: 4,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: AppColors.thirdColor,
                  ),
                  child: Text(
                    'Log Keluar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: MediaQuery.of(context).size.width * 0.065,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionContainer(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(icon),
            color: AppColors.secondaryColor,
            iconSize: MediaQuery.of(context).size.width * 0.1,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _changeName(BuildContext context) {
    TextEditingController newUsernameController = TextEditingController();
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 330,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
                top: BorderSide(width: 8, color: AppColors.secondaryColor)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          iconSize: 40,
                          color: AppColors.secondaryColor,
                          alignment: Alignment.topRight,
                        ),
                      ],
                    ),
                    const Text(
                      'Tukar nama pengguna',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 20, left: 20),
                      child: TextField(
                        controller: newUsernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.secondaryColor,
                              width: 3,
                            ),
                          ),
                          hintText: 'Masukkan nama',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 5,
                              color: AppColors.secondaryColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        player.play(AssetSource('audio/button.mp3'));
                        Future.delayed(Duration(milliseconds: 500), () {
                          changeUsername(newUsernameController.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 65,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.secondaryColor),
                        child: Text(
                          'Sahkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.backgroundColor),
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
    );
  }

  Future _ChangePassword(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 330,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
                top: BorderSide(width: 8, color: AppColors.secondaryColor)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          iconSize: 40,
                          color: AppColors.secondaryColor,
                          alignment: Alignment.topRight,
                        ),
                      ],
                    ),
                    const Text(
                      'Tukar kata laluan',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 20, left: 20),
                      child: TextField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.secondaryColor,
                              width: 3,
                            ),
                          ),
                          hintText: 'Masukkan kata laluan baru',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 5,
                              color: AppColors.secondaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        player.play(AssetSource('audio/button.mp3'));
                        Future.delayed(Duration(milliseconds: 500), () {
                          changePassword(newPasswordController.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 65,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.secondaryColor),
                        child: Text(
                          'Sahkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                    )
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
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 330,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
                top: BorderSide(width: 8, color: AppColors.secondaryColor)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          icon: const Icon(Icons.cancel_rounded),
                          iconSize: 40,
                          color: AppColors.secondaryColor,
                          alignment: Alignment.topRight,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Set semula markah',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Adakah anda pasti untuk set semula markah?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isConfirming = true;
                        });
                        player.play(AssetSource('audio/logout.mp3'));
                        resetScore();
                        await updateRank();
                        showAutoDismissAlertDialog(context,
                            'Markah berjaya di set', 'assets/success.png');

                        setState(() {
                          _isConfirming = false;
                        });

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 200,
                        height: 65,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.secondaryColor,
                        ),
                        child: _isConfirming
                            ? CircularProgressIndicator(
                                color: AppColors.primaryColor)
                            : Text(
                                'Sahkan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                      ),
                    )
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
