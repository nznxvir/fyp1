import 'package:flutter/material.dart';
import 'dart:async';

import 'page/Colors.dart'; // For the Timer class

showAutoDismissAlertDialog(
    BuildContext context, String message, String imagePath) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Timer(Duration(seconds: 3), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return AnimatedAlertDialog(message: message, imagePath: imagePath);
    },
  );
}

class AnimatedAlertDialog extends StatefulWidget {
  final String message;
  final String imagePath;

  const AnimatedAlertDialog({required this.message, required this.imagePath});

  @override
  _AnimatedAlertDialogState createState() => _AnimatedAlertDialogState();
}

class _AnimatedAlertDialogState extends State<AnimatedAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _animation,
            child: SizedBox(
              height: 70,
              width: 70,
              child: Image.asset(widget.imagePath),
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
