import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:badges/badges.dart' as badges;
import 'package:biblechamps/dialogs/bonusgems.dart';
import 'package:biblechamps/dialogs/celebrations.dart';
import 'package:biblechamps/dialogs/champions.dart';
import 'package:biblechamps/dialogs/dailyaffirmations.dart';
import 'package:biblechamps/dialogs/gate.dart';
import 'package:biblechamps/dialogs/memoryverses.dart';
import 'package:biblechamps/dialogs/profile.dart';
import 'package:biblechamps/dialogs/settings.dart';
import 'package:biblechamps/dialogs/wordoftheday.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool stopBack = false;

  Timer? timer;
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 3,
    remindDays: 3,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.biblechamps.app',
    appStoreIdentifier: '1611312724',
  );

  Future launchResources() async {
    bool isGranted = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const ParentalGate(),
    );

    if (isGranted == true) {
      String url = DatabaseService().resourceUrl!;

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future checkUpdate() async {
    if (DatabaseService().hasAndroidUpdate()) {
      int max = 30;
      int days = DateTime.now()
          .toUtc()
          .difference(DateTime.fromMillisecondsSinceEpoch(
            DatabaseService().androidUpdateTime!,
          ).toUtc())
          .inDays;
      int daysLeft = max - days;
      bool valid = daysLeft > 0;
      String description;

      stopBack = !valid;

      if (valid) {
        description =
            'A new version of Bible Champs (v${DatabaseService().androidVersionUpdate}) is available! Your current version would stop working in $daysLeft day(s)!! Stay up to date with latest features, upgrades, games, and more. Update now!!!';
      } else {
        description =
            'A new version of Bible Champs (v${DatabaseService().androidVersionUpdate}) is available! Your current version is outdated!! Stay up to date with latest features, upgrades, games, and more. Update now!!!';
      }

      UiService().showAlert(
        context,
        isWarning: valid,
        isError: !valid,
        title: 'Update App',
        desc: description,
        canDismiss: valid,
        hasCancelButton: valid,
        cancelButtonText: 'LATER',
        buttonText: 'UPDATE NOW',
        onClick: () async {
          String url = DatabaseService().dynamicUrl!;

          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
      );
    }
  }

  bool outdated() {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(DatabaseService().lastValidated)
            .toUtc();
    DateTime dateFuture = date.add(const Duration(days: 30));
    DateTime now = DateTime.now().toUtc();

    if (now.isAfter(dateFuture)) {
      UiService().showAlert(
        context,
        isWarning: true,
        title: 'Outdated',
        desc:
            'Current database is out of date. Update application data in settings and try again!',
      );
    }

    return now.isAfter(dateFuture);
  }

  void showDailyWordAffirmation() {
    if (!outdated()) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => const DailyAffirmations(),
      );
    }
  }

  void showWordOfTheDay() {
    if (!outdated()) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => const WordOfTheDay(),
      );
    }
  }

  void showMemoryVerses() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const MemoryVerses(),
    );
  }

  void showBonusGems() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const BonusGems(),
    );
  }

  void showCelebrations() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const Celebrations(),
    );
  }

  Future showChampions(mode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    timer = Timer(const Duration(seconds: 5), () => Navigator.pop(context));

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Champions(mode),
    );

    timer?.cancel();
  }

  Future prepare() async {
    AudioService().playMusic();
    await Future.delayed(const Duration(milliseconds: 300));

    AudioService().sayVoice(
      const Duration(seconds: 3, milliseconds: 500),
      const Duration(seconds: 3, milliseconds: 250),
    );

    await checkUpdate();

    if (DatabaseService().champions != null) {
      if (!DatabaseService().dayChampionShown) {
        await showChampions('day');
        DatabaseService().dayChampionShown = true;
      } else if (!DatabaseService().weekChampionShown) {
        await showChampions('week');
        DatabaseService().weekChampionShown = true;
      } else if (!DatabaseService().monthChampionShown) {
        await showChampions('month');
        DatabaseService().monthChampionShown = true;
      }
    }

    rateMyApp.init().then((_) async {
      if (rateMyApp.shouldOpenDialog) {
        await Future.delayed(const Duration(milliseconds: 500));
        await rateMyApp.showRateDialog(
          context,
          title: 'Rate this app',
          // The dialog title.
          message:
              "If you like this app, please take a little bit of your time to review it!\nIt really helps us and it shouldn't take you more than one minute.",
          // The dialog message.
          rateButton: 'RATE',
          // The dialog "rate" button text.
          noButton: 'NO THANKS',
          // The dialog "no" button text.
          laterButton: 'MAYBE LATER',
          // The dialog "later" button text.
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
              .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
        );
      }
    });
  }

  bool interceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return true;
    return stopBack;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptor);
    prepare();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DoubleBackToCloseApp(
        child: Container(
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
                        child: Container(
                          width: 82.67,
                          height: 50,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-wordoftheday.png')),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                            ),
                            onPressed: () {
                              AudioService().sayVoice(
                                const Duration(seconds: 18, milliseconds: 750),
                                const Duration(seconds: 2),
                              );
                              showWordOfTheDay();
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
                        child: Container(
                          width: 82.67,
                          height: 50,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-dailywordaffirmation.png')),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                            ),
                            onPressed: () {
                              AudioService().playVoiceOnce(
                                '${DatabaseService().downloadPath}/audios/dailywordaffirmations.mp3',
                                const Duration(seconds: 7),
                              );
                              showDailyWordAffirmation();
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
                        child: Container(
                          width: 82.67,
                          height: 50,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-memoryverses.png')),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                            ),
                            onPressed: () {
                              AudioService().saySecondary(
                                const Duration(seconds: 2),
                                const Duration(seconds: 4),
                              );
                              showMemoryVerses();
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 62.5,
                    height: 62.5,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: badges.Badge(
                            badges.badgeContent: const Text(
                              'FREE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            badges.badgeColor: Colors.orange,
                            padding: const EdgeInsets.all(3.0),
                            shape: badges.BadgeShape.square,
                            toAnimate: true,
                            position:
                                badges.BadgePosition.bottomEnd(bottom: 10, end: 0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () => showBonusGems(),
                              child: Image.file(File(
                                  '${DatabaseService().downloadPath}/images/gem.png')),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => showBonusGems(),
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-resources.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                launchResources();
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-celebration.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () => showCelebrations(),
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-profile.png')),
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
                                      const Profile(),
                                );
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-settings.png')),
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
                                      const Settings(),
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
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 133.93,
                            height: 225,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-playgames.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () async {
                                AudioService().sayVoice(
                                  const Duration(seconds: 8, milliseconds: 300),
                                  const Duration(seconds: 1, milliseconds: 850),
                                );
                                Navigator.of(context).pushNamed('/playgames');
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 133.93,
                            height: 225,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-watchvideos.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                AudioService().sayVoice(
                                  const Duration(seconds: 6, milliseconds: 250),
                                  const Duration(seconds: 2, milliseconds: 250),
                                );
                                Navigator.of(context).pushNamed('/watchvideos');
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 133.93,
                            height: 225,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-singsongs.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                AudioService().sayVoice(
                                  const Duration(seconds: 10),
                                  const Duration(seconds: 2, milliseconds: 100),
                                );
                                Navigator.of(context).pushNamed('/singsongs');
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 133.93,
                            height: 225,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-biblestories.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                AudioService().playVoiceOnce(
                                  '${DatabaseService().downloadPath}/audios/biblestories.mp3',
                                  const Duration(seconds: 2),
                                );
                                Navigator.of(context)
                                    .pushNamed('/biblestories');
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    BackButtonInterceptor.remove(interceptor);
    super.dispose();
  }
}
