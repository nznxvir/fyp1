import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp1/constructor/Database.dart';

class AuthService {
  var database = Database();
  Future<void> createUser(data, context, Function onSuccess) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      await database.addUser(data, context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Register Successful"),
            content: Text("New User Created"),
          );
        },
      );
      onSuccess(); // Invoke the callback function after successful registration
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign Up Failed"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> validateUser(data, context, Function onSuccess) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Successful"),
            content: Text("You have successfully logged in."),
          );
        },
      );
      onSuccess();
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Login Failed"),
              content: Text(e.toString()),
            );
          });
    }
  }
}
