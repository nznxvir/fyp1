import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogTest extends StatelessWidget {
  const LogTest({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Image(
              image: AssetImage('assets/loginlogo.png'),
              width: 200,
              height: 200,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Selamat Kembali',
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    hoverColor: Color(0xFF5F6F52),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xFFFFC55A),
                    ),
                    hintText: 'Email',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 4,
                          color: Color(0xFF00215E),
                        ),
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
