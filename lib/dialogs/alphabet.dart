import 'dart:io';

import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class Alphabet extends StatelessWidget {
  final String char;
  final Map script;

  const Alphabet(this.char, this.script, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 609 * (MediaQuery.of(context).size.height * 0.8) / 842,
          height: MediaQuery.of(context).size.height * 0.8,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/letter-$char-info.jpg')),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            height: 75,
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: Colors.black.withOpacity(0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  script['highlight'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  script['description'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
