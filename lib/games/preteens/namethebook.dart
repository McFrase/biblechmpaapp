import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class PreteensNameTheBookGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreteensNameTheBookGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreteensNameTheBookGameState createState() => PreteensNameTheBookGameState();
}

class PreteensNameTheBookGameState extends GameState<PreteensNameTheBookGame> {
  PreteensNameTheBookGameState() : super('preteens', 'namethebook');

  List? optionColors;

  void evaluateGame(int option) {
    selected = true;

    if (option == question!['answer']) {
      setState(() => optionColors![option - 1] = Colors.green);
      evaluate(true);
    } else {
      setState(() => optionColors![option - 1] = Colors.red);
      evaluate(false);
    }
  }

  @override
  void refreshGame() {
    optionColors = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
  }

  @override
  Widget nextGame() {
    return PreteensNameTheBookGame(
      index: index! + 1,
      accumulator: accumulator,
      valid: valid,
    );
  }

  @override
  void initState() {
    super.initState();

    initializeGame(
      widget.index,
      widget.valid,
      widget.accumulator,
      widget.randomMode,
    );

    refreshGame();

    max = 10;
    value = 100;
    background = 'bg-14.jpg';
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElasticInLeft(
          delay: const Duration(milliseconds: 500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/bg-text.jpg')),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              width: 300,
              height: 225,
              child: Text(
                question!['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(-1.25, 1.25),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            JelloIn(
              delay: const Duration(milliseconds: 1000),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: optionColors![0],
                  fixedSize: const Size(300, 40),
                ),
                onPressed: () => !selected ? evaluateGame(1) : null,
                child: Text(
                  question!['option1'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            JelloIn(
              delay: const Duration(milliseconds: 1750),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: optionColors![1],
                  fixedSize: const Size(300, 40),
                ),
                onPressed: () => !selected ? evaluateGame(2) : null,
                child: Text(
                  question!['option2'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            JelloIn(
              delay: const Duration(milliseconds: 2500),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: optionColors![2],
                  fixedSize: const Size(300, 40),
                ),
                onPressed: () => !selected ? evaluateGame(3) : null,
                child: Text(
                  question!['option3'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            JelloIn(
              delay: const Duration(milliseconds: 3250),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: optionColors![3],
                  fixedSize: const Size(300, 40),
                ),
                onPressed: () => !selected ? evaluateGame(4) : null,
                child: Text(
                  question!['option4'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return super.build(context);
  }
}
