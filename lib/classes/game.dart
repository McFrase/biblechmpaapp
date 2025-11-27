import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:badges/badges.dart' as badges;
import 'package:biblechamps/dialogs/didyouknow.dart';
import 'package:biblechamps/dialogs/gallery.dart';
import 'package:biblechamps/pages/score.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/game.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

abstract class GameState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  GameState(this.type, this.game);

  int? max;
  int? value;
  int? level;
  int? score;
  int? index;
  int? valid;
  int? duration;
  int? multiplier;
  int? accumulator;
  Widget? fab;
  Widget? gameWidget;
  Widget? hintContent;
  String? type;
  String? game;
  String? background;
  Timer? timer;
  Timer? fabTimer;
  Map? question;
  Function()? saveButtonOnPressed;

  int delay = 0;
  int countdown = 30;
  bool hasHint = false;
  bool hideHint = false;
  bool selected = false;
  bool randomMode = false;
  bool fabPressed = false;
  bool fabAnimate = false;
  Color timerColor = Colors.green;

  final CountdownController countdownController = CountdownController(
    autoStart: true,
  );

  int get maxValue => max! * value!;

  // override this
  // used to reset game state
  // call in initState()
  void refreshGame() {}

  // must override this
  // used to build the next game instance
  Widget nextGame();

  // used to initialize state fields
  void initializeGame(
    int? index,
    int? valid,
    int? accumulator,
    bool? randomMode,
  ) {
    this.index = index ?? 1;
    this.valid = valid ?? 0;
    this.accumulator = accumulator ?? 0;
    if (randomMode != null) this.randomMode = randomMode;
  }

  void leaveGame([bool toHome = false]) {
    UiService().showAlert(
      context,
      title: 'Are you sure?',
      isWarning: true,
      hasCancelButton: true,
      cancelButtonText: 'STAY',
      cancelButtonColor: Colors.orange,
      buttonText: 'LEAVE',
      buttonColor: Colors.red,
      onClick: () {
        if (toHome) {
          Navigator.of(context).popUntil(
            ModalRoute.withName('/home'),
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/list${type}games',
            ModalRoute.withName('/playgames'),
          );
        }
      },
    );
  }

  void animateFAB() {
    fabTimer = Timer(const Duration(milliseconds: 6500), () {
      if (selected == false && fabPressed == false) {
        fabAnimate = true;
        setState(() {});
      }
    });
  }

  void updateMissions(String type, String mission, int amount) async {
    Map? missionInfo =
        await DatabaseService().updateMissions(type, mission, amount);

    if (missionInfo != null) {
      AudioService().playChime();

      Future.delayed(Duration(milliseconds: delay)).then((_) async {
        delay += 1250;

        UiService().showAchievement(
          context,
          title: 'Mission Complete!',
          subTitle: missionInfo['mission'],
          icon: missionInfo['icon'],
        );

        Future.delayed(const Duration(milliseconds: 1250), () => delay -= 1250);
      });
    }
  }

  int accolade(bool result) {
    int rand;

    if (result) {
      rand = DatabaseService().randomBetween(1, 6);

      if (rand == 1) {
        AudioService().sayVoice(
          const Duration(minutes: 1, seconds: 14, milliseconds: 250),
          const Duration(seconds: 2, milliseconds: 150),
        );
      }

      if (rand == 2) {
        AudioService().sayVoice(
          const Duration(minutes: 1, seconds: 12, milliseconds: 250),
          const Duration(seconds: 2, milliseconds: 300),
        );
      }

      if (rand == 3) {
        AudioService().playVoiceOnce(
          '${DatabaseService().downloadPath}/audios/youarespecial.mp3',
          const Duration(seconds: 2, milliseconds: 250),
        );
      }

      if (rand == 4) {
        AudioService().playVoiceOnce(
          '${DatabaseService().downloadPath}/audios/youaresmart.mp3',
          const Duration(seconds: 2, milliseconds: 250),
        );
      }

      if (rand == 5) {
        AudioService().playVoiceOnce(
          '${DatabaseService().downloadPath}/audios/youarewonderful.mp3',
          const Duration(seconds: 2, milliseconds: 250),
        );
      }
    } else {
      rand = DatabaseService().randomBetween(1, 4);

      if (rand == 1) {
        AudioService().sayVoice(
          const Duration(minutes: 1, seconds: 10),
          const Duration(seconds: 2, milliseconds: 650),
        );
      }

      if (rand == 2) {
        AudioService().sayVoice(
          const Duration(minutes: 1, seconds: 7),
          const Duration(seconds: 3),
        );
      }

      if (rand == 3) {
        AudioService().sayVoice(
          const Duration(minutes: 1, seconds: 4, milliseconds: 700),
          const Duration(seconds: 2, milliseconds: 500),
        );
      }
    }

    return rand;
  }

  void evaluate(bool result, [int? subvalue]) async {
    countdownController.pause();
    AudioService().normalizeMusic();

    if (result) {
      int reward = ((subvalue ?? value!) * multiplier!).round();

      valid = valid! + 1;
      score = score! + reward;
      accumulator = accumulator! + reward;

      updateMissions(type!, game!, 1);
      DatabaseService().setLeaderboardData(type, reward);

      UiService().showAlert(
        context,
        imagePath:
            '${DatabaseService().downloadPath}/images/accolades-$type-${accolade(result)}.png',
        buttonText: 'YAY!',
        onPop: () {
          if (score! >= (level! * maxValue)) {
            levelUp();
          } else {
            next();
          }
        },
      );
    } else {
      UiService().showAlert(
        context,
        imagePath:
            '${DatabaseService().downloadPath}/images/accolades-tryagain-${accolade(result)}.png',
        hasCancelButton: true,
        buttonText: 'TRY AGAIN',
        onClick: () => retry(),
        onPop: () => next(),
        buttonWillClick: DatabaseService().gems! >= 1,
      );
    }

    setState(() {});
  }

  void levelUp() async {
    score = score! % (level! * maxValue);
    level = level! + 1;

    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      AudioService().sayVoice(
        const Duration(minutes: 1, seconds: 19, milliseconds: 500),
        const Duration(seconds: 2, milliseconds: 50),
      );

      UiService().showAlert(
        context,
        imagePath:
            "${DatabaseService().downloadPath}/images/levelup-${type == 'preteens' ? 3 : 2}.png",
        buttonText: 'HOORAY!',
        onPop: () => next(),
      );
    });

    updateMissions(type!, 'levelup', 1);

    if (level! % 10 == 0) {
      DatabaseService().gems = DatabaseService().gems! + 10;
      AudioService().playChime();

      delay += 1250;

      Future.delayed(Duration(milliseconds: delay)).then((_) {
        UiService().showAchievement(
          context,
          title: 'Congratulations!',
          subTitle: 'You have received 10 Gems in your treasury',
          icon: FontAwesomeIcons.gem,
        );

        Future.delayed(const Duration(milliseconds: 1250), () => delay -= 1250);
      });

      updateMissions(type!, 'getgems', 10);
    }
  }

  void retry() {
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      UiService().showAlert(
        context,
        title: 'Try Again?',
        desc: 'This would cost 1 Gem. Proceed?',
        isWarning: true,
        hasCancelButton: true,
        cancelButtonText: 'NO',
        buttonText: 'TRY AGAIN',
        onClick: () {
          selected = false;
          hideHint = false;
          timerColor = Colors.green;
          DatabaseService().gems = DatabaseService().gems! - 1;

          updateMissions(type!, 'usegems', 1);
          countdownController.restart();
          refreshGame();
          setState(() {});
        },
        onPop: () => next(),
      );
    });
  }

  void next() async {
    await Future.delayed(const Duration(milliseconds: 1250));

    if (type == 'nursery') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation1,
                  Animation<double> animation2) =>
              nextGame(),
        ),
      );

      return;
    }

    await DatabaseService().setGameData('$type-$game', level, score);

    await Future.delayed(const Duration(milliseconds: 500));

    if (DatabaseService().randomBetween(1, 10) % 4 == 0) {
      timer = Timer(const Duration(seconds: 10), () => Navigator.pop(context));

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => DidYouKnow(),
      );

      timer?.cancel();

      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (index == max) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ScorePage(
            game: '$type-$game',
            action: '/play$type$game',
            accumulator: accumulator!,
            percentage: (valid! / max!) * 100,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation1,
                  Animation<double> animation2) =>
              randomMode ? GameService().getRandomGame(type!) : nextGame(),
        ),
      );
    }
  }

  bool interceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return true;
    if (info.ifRouteChanged(context)) return false;

    leaveGame();

    return true;
  }

  Map? getQuestion() {
    List? questions;

    if (game == 'jigsawpuzzle' || game == 'scratchtoreveal') {
      questions = DatabaseService().gamePictures;
    } else {
      questions = DatabaseService().getGameData(type, game);
    }

    if (questions == null) return null;

    return questions[DatabaseService().randomBetween(0, questions.length)];
  }

  @override
  void initState() {
    super.initState();
    animateFAB();
    BackButtonInterceptor.add(interceptor, context: context);

    multiplier = DatabaseService().getMultiplier(type);
    level = DatabaseService().getLevel('$type-$game') ?? 1;
    score = DatabaseService().getScore('$type-$game') ?? 0;
    question = getQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // prevent fab moving up with keyboard
      body: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: background != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/$background')),
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.75),
                    BlendMode.dstATop,
                  ),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
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
                                    onPressed: () => leaveGame(),
                                    child: const SizedBox(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
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
                                    onPressed: () => leaveGame(true),
                                    child: const SizedBox(),
                                  ),
                                ),
                              ),
                            ),
                            if (type == 'preteens') const SizedBox(width: 50),
                          ],
                        ),
                        if (!randomMode && max != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Text(
                              '$index of $max',
                              style: const TextStyle(
                                fontSize: 50,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1.5, 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            if (type != 'nursery')
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 7.5, 7.5, 7.5),
                                    child: Text(
                                      'Level $level',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  LinearPercentIndicator(
                                    width: 75.0,
                                    animation: false,
                                    animationDuration: 2000,
                                    lineHeight: 5.0,
                                    percent: score! / (level! * maxValue),
                                    barRadius: Radius.circular(10),
                                    progressColor: Colors.green,
                                  ),
                                ],
                              ),
                            if (type != 'nursery')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 7.5, 20, 7.5),
                                child: Badge(
                                  badgeContent: Padding(
                                    padding: const EdgeInsets.all(2.5),
                                    child: Text(
                                      '${DatabaseService().gems}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  badgeColor: Colors.orange,
                                  toAnimate: false,
                                  position:
                                      BadgePosition.topEnd(top: 5, end: -10),
                                  child: Image.file(
                                    File(
                                        '${DatabaseService().downloadPath}/images/gem.png'),
                                    width: 50,
                                  ),
                                ),
                              ),
                            if (type == 'preteens')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 7.5, 20, 7.5),
                                child: Badge(
                                  badgeContent: Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    child: Countdown(
                                      seconds: countdown,
                                      controller: countdownController,
                                      build:
                                          (BuildContext context, double time) {
                                        Future(() {
                                          if (time == 20) {
                                            timerColor = Colors.orange;
                                          } else if (time == 10) {
                                            hideHint = true;
                                            timerColor = Colors.red;
                                            AudioService().pauseMusic();
                                            AudioService().clockTick();
                                          }

                                          setState(() {});
                                        });

                                        return Text(
                                          '${time.round()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        );
                                      },
                                      onFinished: () => evaluate(false),
                                    ),
                                  ),
                                  badgeColor: timerColor,
                                  toAnimate: false,
                                  position: BadgePosition.topEnd(
                                    top: 5,
                                    end: -12.5,
                                  ),
                                  child: Image.file(
                                    File(
                                        '${DatabaseService().downloadPath}/images/stopwatch.png'),
                                    height: 50,
                                  ),
                                ),
                              ),
                            if (game == 'coloringgame')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 7.5, 7.5, 7.5),
                                child: ClipOval(
                                  child: Container(
                                    width: 48.91,
                                    height: 50,
                                    padding: const EdgeInsets.all(0.0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(
                                            '${DatabaseService().downloadPath}/images/button-save.png')),
                                      ),
                                    ),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0.0),
                                      ),
                                      onPressed: saveButtonOnPressed,
                                      child: const SizedBox(),
                                    ),
                                  ),
                                ),
                              ),
                            if (game == 'coloringgame')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 7.5, 7.5, 7.5),
                                child: ClipOval(
                                  child: Container(
                                    width: 48.91,
                                    height: 50,
                                    padding: const EdgeInsets.all(0.0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(
                                            '${DatabaseService().downloadPath}/images/button-gallery.png')),
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
                                          builder: (BuildContext context) =>
                                              const Gallery(),
                                        );
                                      },
                                      child: const SizedBox(),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(child: gameWidget!),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: hasHint && !hideHint
          ? Bounce(
              animate: fabAnimate,
              from: 200,
              child: Roulette(
                animate: fabAnimate,
                child: FloatingActionButton.extended(
                  onPressed: !selected
                      ? () {
                          fabPressed = true;

                          UiService().showAlert(
                            context,
                            isInfo: true,
                            title: 'HINT',
                            desc: question!['hint'],
                            content: hintContent,
                          );
                        }
                      : null,
                  label: const Text(
                    'HELP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  icon: const FaIcon(
                    IconDataSolid(0xf0eb),
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : fab,
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptor);
    AudioService().normalizeMusic();
    fabTimer?.cancel();
    super.dispose();
  }
}
