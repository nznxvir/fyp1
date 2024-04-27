import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(top: 50),
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(30), left: Radius.circular(30)),
                  color: Color(0xFF074173),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _getImage();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            color: Colors.white),
                        width: 150,
                        height: 150,
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
                    ),
                    Text(
                      username,
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFFC6A969)),
                    ),
                    Text(
                      age,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFFC6A969)),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color(0xFF5F6F52)),
                width: double.infinity,
                height: 58,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Username',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFC6A969),
                        iconSize: 35,
                        onPressed: () {
                          _changeName(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color(0xFF5F6F52)),
                width: double.infinity,
                height: 58,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change passsword',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFC6A969),
                        iconSize: 35,
                        onPressed: () {
                          _ChangePassword(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color(0xFF5F6F52)),
                width: double.infinity,
                height: 58,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reset Score',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFC6A969),
                        iconSize: 35,
                        onPressed: () {
                          _ResetScore(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  logout();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Color(0xFF5F6F52)),
                  minimumSize: MaterialStateProperty.all<Size>(Size(270, 64)),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 60, 20, 10),
                height: 65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFF5F6F52)),
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
                          MaterialPageRoute(builder: (context) => RankView()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.abc_outlined),
                      color: Colors.white,
                      iconSize: 35,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryView()),
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
                          MaterialPageRoute(builder: (context) => HomeView()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person),
                      color: Color(0xFFC6A969),
                      iconSize: 35,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileView()),
                        );
                      },
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
