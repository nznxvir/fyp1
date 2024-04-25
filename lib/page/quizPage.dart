import 'package:flutter/material.dart';

class QuizView extends StatefulWidget {
  final String setId;
  const QuizView({super.key, required this.setId});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late String setId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Text(
          setId,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
