import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/constructor/Database.dart';

import '../alertBox.dart';

class AuthService {
  var database = Database();
  Future<void> createUser(data, context, Function onSuccess) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      await database.addUser(data, context);
      onSuccess();
    } catch (e) {
      showAutoDismissAlertDialog(context, e.toString(), 'assets/failed.png');
    }
  }

  Future<void> validateUser(data, context, Function onSuccess) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      onSuccess();
    } catch (e) {
      showAutoDismissAlertDialog(
          context, 'Log masuk gagal. Sila cuba lagi', 'assets/failed.png');
    }
  }
}
