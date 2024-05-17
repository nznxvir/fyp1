import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _changeName(BuildContext context) {
  TextEditingController newUsernameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> changeUsername(String newUsername) async {
    if (user != null) {
      await user.updateDisplayName(newUsername);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});
    }
  }

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
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            minimumSize: MaterialStateProperty.all<Size>(
                                const Size(130, 60)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black, fontSize: 18),
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
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
