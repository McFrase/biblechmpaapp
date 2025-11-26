import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:validators/validators.dart';

class NurseryAbcGameGame extends StatefulWidget {
  const NurseryAbcGameGame({Key? key}) : super(key: key);

  @override
  NurseryAbcGameGameState createState() => NurseryAbcGameGameState();
}

class NurseryAbcGameGameState extends GameState<NurseryAbcGameGame> {
  NurseryAbcGameGameState() : super('nursery', 'abcgame');

  String? current;
  Timer? sayAlphabet;
  List options = [];

  List? optionColors;

  void evaluateGame(int option) {
    selected = true;

    if (options[option] == current) {
      setState(() => optionColors![option] = Colors.green.withOpacity(0.5));

      UiService().showAlert(
        context,
        imagePath:
            '${DatabaseService().downloadPath}/images/accolades-nursery-${accolade(true)}.png',
        buttonText: 'YAY!',
        onPop: () => next(),
      );
    } else {
      setState(() => optionColors![option] = Colors.red.withOpacity(0.5));

      UiService().showAlert(
        context,
        imagePath:
            '${DatabaseService().downloadPath}/images/accolades-tryagain-${accolade(false)}.png',
        hasCancelButton: true,
        buttonText: 'TRY AGAIN',
        onClick: () {
          setState(() => refreshGame());

          Future.delayed(
            const Duration(milliseconds: 1000),
            () => selected = false,
          );
        },
        onPop: () => next(),
      );
    }
  }

  Widget buildLetter(String value) {
    return ElasticIn(
      delay: Duration(milliseconds: (options.indexOf(value) + 1) * 750),
      child: Container(
        height: 90,
        width: 90,
        margin: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 5,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: optionColors![options.indexOf(value)],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0.0),
          ),
          onPressed: () => evaluateGame(options.indexOf(value)),
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(
                    '${DatabaseService().downloadPath}/images/letter-$value.png')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void refreshGame() {
    optionColors = [
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
    ];
  }

  @override
  Widget nextGame() {
    return const NurseryAbcGameGame();
  }

  @override
  void initState() {
    super.initState();
    refreshGame();

    background = 'bg-10.jpg';

    sayAlphabet = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      if (selected == false) AudioService().sayAlphabets(current);
    });

    for (int i = 0; i < 5; i++) {
      String rand;

      do {
        rand = randomAlpha(1).toLowerCase();
      } while (isIn(rand, options)!);

      options.add(rand);
    }

    current = options[DatabaseService().randomBetween(0, 5)];
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.75),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                'Identify the correct letter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: options.map<Widget>((value) {
                  return buildLetter(value);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );

    return super.build(context);
  }

  @override
  void dispose() {
    sayAlphabet?.cancel();
    super.dispose();
  }
}
