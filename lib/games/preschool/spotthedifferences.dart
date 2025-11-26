import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PreschoolSpotTheDifferencesGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreschoolSpotTheDifferencesGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreschoolSpotTheDifferencesGameState createState() =>
      PreschoolSpotTheDifferencesGameState();
}

class PreschoolSpotTheDifferencesGameState
    extends GameState<PreschoolSpotTheDifferencesGame> {
  PreschoolSpotTheDifferencesGameState()
      : super('preschool', 'spotthedifferences');

  File? file1;
  File? file2;
  double height = 0;
  int wrongCounter = 0;
  int maxDifferences = 7;
  List? progress;
  List? differences;

  void evaluateGame() {
    selected = true;
    int count = 0;

    for (var value in progress!) {
      if (value) count++;
    }

    if (((count / progress!.length) * 100) >= 50) {
      evaluate(true, ((count / progress!.length) * 100).round());
    } else {
      evaluate(false);
    }
  }

  void handleTap(index) {
    if (!selected) {
      if (index != null) {
        if (!progress![index]) {
          bool done = true;
          progress![index] = true;

          AudioService().playChime();
          setState(() {});

          for (var value in progress!) {
            if (!value) {
              done = false;
              return;
            }
          }

          if (done) evaluateGame();
        }
      }

      wrongCounter++;
      AudioService().playBuzz();

      if (wrongCounter >= 3) evaluateGame();
    }
  }

  Widget getDifference(index) {
    return GestureDetector(
      onTap: () {
        handleTap(null);
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(index == 1 ? file1! : file2!),
            fit: BoxFit.cover,
          ),
        ),
        height: height,
        child: AspectRatio(
          aspectRatio: 250 / 351,
          child: Stack(
            children: differences!.asMap().entries.map((entry) {
              return Positioned(
                top: (height / maxDifferences) * entry.value['top'],
                left: (height / maxDifferences) * entry.value['left'],
                child: GestureDetector(
                  onTap: () => handleTap(entry.key),
                  child: Opacity(
                    opacity: progress![entry.key] ? 1.0 : 0.0,
                    child: DottedBorder(
                      borderType: BorderType.Circle,
                      padding: const EdgeInsets.all(2.5),
                      color: Colors.white,
                      strokeWidth: 1.5,
                      dashPattern: const [10, 5],
                      child: Container(
                        width:
                            (height / maxDifferences) * entry.value['radius'],
                        height:
                            (height / maxDifferences) * entry.value['radius'],
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget nextGame() {
    return PreschoolSpotTheDifferencesGame(
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

    max = 10;
    value = 100;
    background = 'bg-6.jpg';
    file1 = File(
        "${DatabaseService().downloadPath}/spotthedifferences/${question!['image1']}");
    file2 = File(
        "${DatabaseService().downloadPath}/spotthedifferences/${question!['image2']}");

    Future(() {
      setState(() => height = MediaQuery.of(context).size.height * 0.70);
    });

    differences = DatabaseService()
        .getGameData('preschool', 'differences')!
        .where((difference) =>
            difference['spotthedifferencesid'] == question!['id'])
        .take(maxDifferences)
        .toList();

    progress = List.filled(differences!.length, false);
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getDifference(1),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: height,
          child: AspectRatio(
            aspectRatio: 60 / 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: progress!.map((value) {
                return value
                    ? ElasticIn(
                        child: Image.file(
                          File(
                              '${DatabaseService().downloadPath}/images/button-state-1.png'),
                          width: (height / maxDifferences) * 0.8,
                        ),
                      )
                    : Image.file(
                        File(
                            '${DatabaseService().downloadPath}/images/button-state-0.png'),
                        width: (height / maxDifferences) * 0.8,
                      );
              }).toList(),
            ),
          ),
        ),
        getDifference(2),
      ],
    );

    fab = FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: !selected ? () => evaluateGame() : null,
      child: const FaIcon(
        FontAwesomeIcons.arrowRight,
        color: Colors.white,
      ),
    );

    return super.build(context);
  }
}
