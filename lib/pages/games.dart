import 'dart:io';

import 'package:biblechamps/dialogs/leaderboard.dart';
import 'package:biblechamps/dialogs/missions.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class GamesPage extends StatelessWidget {
  final String game;
  final Map games = {
    'nursery': [
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-nursery-learnabc.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playnurserylearnabc',
        'seek': Duration.zero,
        'duration': const Duration(milliseconds: 100),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-nursery-abcgame.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playnurseryabcgame',
        'seek': const Duration(seconds: 22, milliseconds: 500),
        'duration': const Duration(seconds: 2, milliseconds: 700),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-nursery-coloringgame.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playnurserycoloringgame',
        'seek': Duration.zero,
        'duration': const Duration(milliseconds: 100),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-nursery-scratchtoreveal.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playnurseryscratchtoreveal',
        'seek': Duration.zero,
        'duration': const Duration(milliseconds: 100),
        'available': true,
      }
    ],
    'preschool': [
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preschool-namethepicture.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playpreschoolnamethepicture',
        'seek': const Duration(seconds: 25),
        'duration': const Duration(seconds: 2, milliseconds: 250),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preschool-fillinthegaps.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playpreschoolfillinthegaps',
        'seek': const Duration(seconds: 32),
        'duration': const Duration(seconds: 2, milliseconds: 500),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preschool-jigsawpuzzle.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playpreschooljigsawpuzzle',
        'seek': const Duration(seconds: 27),
        'duration': const Duration(seconds: 2, milliseconds: 250),
        'available': true,
      },
      /*
      {
        "image": '${DatabaseService().downloadPath}/images/button-preschool-colourthis.png',
        "width": 123.08,
        "height": 200.00,
        "action": '/playpreschoolcolourthis',
        "seek": Duration.zero,
        "duration": Duration.zero,
        "available": false,
      },*/
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preschool-spotthedifferences.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playpreschoolspotthedifferences',
        'seek': const Duration(seconds: 29, milliseconds: 350),
        'duration': const Duration(seconds: 2, milliseconds: 600),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preschool-trickymaze.png',
        'width': 123.08,
        'height': 200.00,
        'action': '/playpreschooltrickymaze',
        'seek': const Duration(seconds: 36, milliseconds: 500),
        'duration': const Duration(seconds: 2, milliseconds: 250),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-randomgames.png',
        'width': 185.71,
        'height': 100.00,
        'action': '/playpreschoolrandomgames',
        'seek': const Duration(seconds: 38, milliseconds: 250),
        'duration': const Duration(seconds: 2, milliseconds: 500),
        'available': true,
      }
    ],
    'preteens': [
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-biblequiz.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteensbiblequiz',
        'seek': const Duration(seconds: 49, milliseconds: 750),
        'duration': const Duration(seconds: 1, milliseconds: 750),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-fillinthegaps.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteensfillinthegaps',
        'seek': const Duration(seconds: 44, milliseconds: 850),
        'duration': const Duration(seconds: 2, milliseconds: 250),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-namethebook.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteensnamethebook',
        'seek': const Duration(seconds: 40, milliseconds: 300),
        'duration': const Duration(seconds: 2),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-trueorfalse.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteenstrueorfalse',
        'seek': const Duration(seconds: 47),
        'duration': const Duration(seconds: 2, milliseconds: 250),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-whosaidthat.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteenswhosaidthat',
        'seek': const Duration(seconds: 41, milliseconds: 900),
        'duration': const Duration(seconds: 2, milliseconds: 500),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-preteens-wordsearch.png',
        'width': 127.00,
        'height': 200.00,
        'action': '/playpreteenswordsearch',
        'seek': const Duration(seconds: 51, milliseconds: 100),
        'duration': const Duration(seconds: 1, milliseconds: 850),
        'available': true,
      },
      {
        'image':
            '${DatabaseService().downloadPath}/images/button-randomgames.png',
        'width': 185.71,
        'height': 100.00,
        'action': '/playpreteensrandomgames',
        'seek': const Duration(seconds: 38, milliseconds: 250),
        'duration': const Duration(seconds: 2, milliseconds: 500),
        'available': true,
      }
    ]
  };

  GamesPage(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/homebg.png'),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.50),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
                      child: ClipOval(
                        child: Container(
                          width: 48.91,
                          height: 50,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-back.png')),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                    if (game == 'preschool' || game == 'preteens')
                      const SizedBox(width: 50),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Image.file(
                    File(
                        "${DatabaseService().downloadPath}/images/text-${game == 'all' ? 'play' : game}games.png"),
                    height: 75,
                  ),
                ),
                game == 'preschool' || game == 'preteens'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                            child: ClipOval(
                              child: Container(
                                width: 48.91,
                                height: 50,
                                padding: const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(
                                        '${DatabaseService().downloadPath}/images/button-missions.png')),
                                  ),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0.0),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => Missions(game),
                                    );
                                  },
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                            child: ClipOval(
                              child: Container(
                                width: 48.91,
                                height: 50,
                                padding: const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(
                                        '${DatabaseService().downloadPath}/images/button-leaderboard.png')),
                                  ),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0.0),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => Leaderboard(game),
                                    );
                                  },
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(width: 50),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: game == 'all'
                        ? ['nursery', 'preschool', 'preteens'].map((value) {
                            return Container(
                              width: 200,
                              height: 200,
                              padding: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(
                                      '${DatabaseService().downloadPath}/images/button-$value.png')),
                                ),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(0.0),
                                ),
                                onPressed: () {
                                  AudioService().sayVoice(
                                    const Duration(seconds: 12),
                                    const Duration(
                                      seconds: 2,
                                      milliseconds: 50,
                                    ),
                                  );
                                  Navigator.of(context)
                                      .pushNamed('/list${value}games');
                                },
                                child: const SizedBox(),
                              ),
                            );
                          }).toList()
                        : games[game].map<Widget>((value) {
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                width: value['width'],
                                height: value['height'],
                                padding: const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(value['image'])),
                                  ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: value['available']
                                          ? Colors.transparent
                                          : Colors.black.withOpacity(0.5),
                                    ),
                                    value['available']
                                        ? const SizedBox()
                                        : Align(
                                            alignment: Alignment.topCenter,
                                            child: Image.file(
                                              File(
                                                  '${DatabaseService().downloadPath}/images/comingsoon.png'),
                                              width: 75,
                                            ),
                                          ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0.0),
                                      ),
                                      onPressed: () async {
                                        if (value['available']) {
                                          if (value['action'] ==
                                              '/playnurserylearnabc') {
                                            AudioService().saySecondary(
                                              const Duration(
                                                seconds: 15,
                                                milliseconds: 750,
                                              ),
                                              const Duration(
                                                seconds: 2,
                                                milliseconds: 250,
                                              ),
                                            );
                                          } else if (value['action'] ==
                                              '/playnurserycoloringgame') {
                                            AudioService().saySecondary(
                                              const Duration(
                                                seconds: 11,
                                                milliseconds: 750,
                                              ),
                                              const Duration(seconds: 2),
                                            );
                                          } else if (value['action'] ==
                                              '/playnurseryscratchtoreveal') {
                                            AudioService().saySecondary(
                                              const Duration(
                                                seconds: 13,
                                                milliseconds: 650,
                                              ),
                                              const Duration(
                                                seconds: 2,
                                                milliseconds: 500,
                                              ),
                                            );
                                          } else if (value['action'] ==
                                              '/playpreteensnamethebook') {
                                            AudioService().playVoiceOnce(
                                              '${DatabaseService().downloadPath}/audios/namethebook.mp3',
                                              const Duration(
                                                seconds: 2,
                                                milliseconds: 100,
                                              ),
                                            );
                                          } else {
                                            AudioService().sayVoice(
                                              value['seek'],
                                              value['duration'],
                                            );
                                          }
                                          Navigator.of(context)
                                              .pushNamed(value['action']);
                                        }
                                      },
                                      child: const SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
