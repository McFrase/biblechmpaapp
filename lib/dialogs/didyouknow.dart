import 'dart:io';

import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class DidYouKnow extends StatelessWidget {
  final List didYouKnow = DatabaseService().didYouKnow!;

  DidYouKnow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.00,
          height: 311.69,
          padding: const EdgeInsets.fromLTRB(25, 75, 25, 25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/bg-didyouknow.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              didYouKnow[DatabaseService().randomBetween(0, didYouKnow.length)]
                  ['text'],
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
