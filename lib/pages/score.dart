import 'dart:io';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ScorePage extends StatefulWidget {
  final String game;
  final String action;
  final int accumulator;
  final double percentage;

  const ScorePage({
    Key? key,
    required this.game,
    required this.action,
    required this.accumulator,
    required this.percentage,
  }) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  List stars = [false, false, false];
  bool isNewBest = false;
  int? best;
  int? newBest;
  Animation<double>? animation;
  AnimationController? controller;
  ConfettiController? confettiController;

  Widget buildStar(bool value) {
    return value
        ? ElasticIn(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Image.file(
                File('${DatabaseService().downloadPath}/images/star.png'),
                width: 80,
              ),
            ),
          )
        : const Padding(
            padding: EdgeInsets.all(12),
            child: FaIcon(
              IconDataRegular(0xf005),
              color: Colors.yellow,
              size: 50,
            ),
          );
  }

  void highScore() {
    DatabaseService().setNewBest(widget.game, widget.accumulator);
    Future.delayed(const Duration(milliseconds: 3000)).then((_) {
      setState(() {
        isNewBest = true;
        newBest = widget.accumulator;
      });
    });

    Future.delayed(const Duration(milliseconds: 4000)).then((_) {
      AudioService().playCheer();
      confettiController!.play();
    });
  }

  @override
  void initState() {
    super.initState();
    AudioService().pauseMusic();

    best = DatabaseService().getBest(widget.game)!;

    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animation = Tween<double>(
      begin: 0,
      end: widget.accumulator.toDouble(),
    ).animate(controller!);

    if (widget.accumulator > best!) highScore();

    animation!.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      controller!.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      if (widget.percentage >= 25) {
        AudioService().playShockWave();
        setState(() => stars[0] = true);
      }
    });

    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      if (widget.percentage >= 50) {
        AudioService().playShockWave();
        setState(() => stars[1] = true);
      }
    });

    Future.delayed(const Duration(milliseconds: 2000)).then((_) {
      if (widget.percentage >= 75) {
        DatabaseService().updateMissions(
          widget.game.contains('preteens') ? 'preteens' : 'preschool',
          'gettripplestars',
          1,
        );

        AudioService().playShockWave();
        setState(() => stars[2] = true);

        Future.delayed(const Duration(milliseconds: 2000)).then((_) {
          DatabaseService().gems = DatabaseService().gems! + 3;

          DatabaseService().updateMissions(
            widget.game.contains('preteens') ? 'preteens' : 'preschool',
            'getgems',
            3,
          );

          AudioService().playChime();

          UiService().showAchievement(
            context,
            title: 'Congratulations!',
            subTitle: 'You have received 3 Gems in your treasury',
            icon: FontAwesomeIcons.gem,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(
                "${DatabaseService().downloadPath}/images/bg-celebration-${widget.game.contains('preteens') ? '1' : '2'}.png")),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.9),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildStar(stars[0]),
                    buildStar(stars[1]),
                    buildStar(stars[2]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SlideInLeft(
                        delay: const Duration(milliseconds: 500),
                        from: 1500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Score',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1.25, 1.25),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              animation!.value.round().toString(),
                              style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2.5, 2.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SlideInRight(
                        delay: const Duration(milliseconds: 500),
                        from: 1500,
                        child: isNewBest
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'New Best',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1.25, 1.25),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Swing(
                                    child: Text(
                                      newBest.toString(),
                                      style: const TextStyle(
                                        fontSize: 50,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(2.5, 2.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Best',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1.25, 1.25),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$best',
                                    style: const TextStyle(
                                      fontSize: 50,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(2.5, 2.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeIn(
                      delay: const Duration(milliseconds: 2000),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-share.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                Share.share(
                                  "I got ${widget.accumulator} on a game in the Bible Champs application. Download the Bible Champs application now. Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child. \n${DatabaseService().dynamicUrl}",
                                  subject: 'Bible Champs',
                                );
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeIn(
                      delay: const Duration(milliseconds: 2500),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-reset.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed(widget.action);
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeIn(
                      delay: const Duration(milliseconds: 3000),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-home.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil(ModalRoute.withName('/home'));
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConfettiWidget(
                confettiController: confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                // don't specify a direction, blast randomly
                blastDirection: -pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 250,
                maxBlastForce: 80,
                minBlastForce: 30,
                gravity: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    AudioService().playMusic();
    super.dispose();
  }
}
