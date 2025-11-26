import 'package:biblechamps/games/preschool/fillinthegaps.dart';
import 'package:biblechamps/games/preschool/jigsawpuzzle.dart';
import 'package:biblechamps/games/preschool/namethepicture.dart';
import 'package:biblechamps/games/preschool/spotthedifferences.dart';
import 'package:biblechamps/games/preschool/trickymaze.dart';
import 'package:biblechamps/games/preteens/biblequiz.dart';
import 'package:biblechamps/games/preteens/fillinthegaps.dart';
import 'package:biblechamps/games/preteens/namethebook.dart';
import 'package:biblechamps/games/preteens/trueorfalse.dart';
import 'package:biblechamps/games/preteens/whosaidthat.dart';
import 'package:biblechamps/games/preteens/wordsearch.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class GameService {
  Widget getRandomGame(String type) {
    Map<String, List<Widget>> games = {
      'preschool': [
        const PreschoolNameThePictureGame(randomMode: true),
        const PreschoolFillInTheGapsGame(randomMode: true),
        const PreschoolJigsawPuzzleGame(randomMode: true),
        const PreschoolSpotTheDifferencesGame(randomMode: true),
        const PreschoolTrickyMazeGame(randomMode: true),
      ]..shuffle(),
      'preteens': [
        const PreteensBibleQuizGame(randomMode: true),
        const PreteensFillInTheGapsGame(randomMode: true),
        const PreteensNameTheBookGame(randomMode: true),
        const PreteensTrueOrFalseGame(randomMode: true),
        const PreteensWhoSaidThatGame(randomMode: true),
        const PreteensWordSearchGame(randomMode: true),
      ]..shuffle(),
    };

    return games[type]![
        DatabaseService().randomBetween(0, games[type]!.length)];
  }
}
