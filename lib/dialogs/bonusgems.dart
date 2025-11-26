import 'package:biblechamps/dialogs/champions.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timer_count_down/timer_count_down.dart';

class BonusGems extends StatefulWidget {
  const BonusGems({Key? key}) : super(key: key);

  @override
  _BonusGemsState createState() => _BonusGemsState();
}

class _BonusGemsState extends State<BonusGems> {
  DateTime bonusNextReward =
      DateTime.fromMillisecondsSinceEpoch(DatabaseService().bonusNextReward!)
          .toUtc();
  DateTime championDayNextReward = DateTime.fromMillisecondsSinceEpoch(
          DatabaseService().championDayNextReward!)
      .toUtc();
  DateTime championWeekNextReward = DateTime.fromMillisecondsSinceEpoch(
          DatabaseService().championWeekNextReward!)
      .toUtc();
  DateTime championMonthNextReward = DateTime.fromMillisecondsSinceEpoch(
          DatabaseService().championMonthNextReward!)
      .toUtc();
  bool bonusCanReward = false;
  bool championDayCanReward = false;
  bool championWeekCanReward = false;
  bool championMonthCanReward = false;

  Future showChampions(mode) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Champions(mode),
    );

    setState(() {});
  }

  void rewardGems(int gems) {
    DatabaseService().gems = DatabaseService().gems! + gems;
    AudioService().playChime();

    UiService().showAchievement(
      context,
      title: 'Congratulations!',
      subTitle: 'You have received $gems Gems in your treasury',
      icon: FontAwesomeIcons.gem,
    );
  }

  Widget buildTime(time) {
    double days = time / (24 * 3600);
    time = time % (24 * 3600);
    double hours = time / 3600;
    time = time % 3600;
    double minutes = time / 60;
    time = time % 60;
    double seconds = time;

    return Text(
      '${days.floor()} days ${hours.floor()} hours ${minutes.floor()} minutes ${seconds.floor()} seconds',
      style: const TextStyle(
        color: Colors.orange,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (DateTime.now().toUtc().isAfter(bonusNextReward)) bonusCanReward = true;
    if (DateTime.now().toUtc().isAfter(championDayNextReward)) {
      championDayCanReward = true;
    }
    if (DateTime.now().toUtc().isAfter(championWeekNextReward)) {
      championWeekCanReward = true;
    }
    if (DateTime.now().toUtc().isAfter(championMonthNextReward)) {
      championMonthCanReward = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: 400,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            ListTile(
              title: const Text('Free Giveaway Gems'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Get free gems everyday'),
                  bonusCanReward
                      ? const SizedBox()
                      : Countdown(
                          seconds: bonusNextReward
                              .difference(DateTime.now().toUtc())
                              .inSeconds,
                          build: (BuildContext context, double time) {
                            return buildTime(time);
                          },
                          onFinished: () {
                            setState(() => bonusCanReward = true);
                          },
                        ),
                ],
              ),
              leading: const FaIcon(FontAwesomeIcons.coffee),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: const Size(75, 40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'GET',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '1 ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 12.5,
                        ),
                      ],
                    ),
                  ],
                ),
                onPressed: bonusCanReward
                    ? () {
                        bonusNextReward =
                            DateTime.now().toUtc().add(const Duration(days: 1));
                        DatabaseService().bonusNextReward =
                            bonusNextReward.millisecondsSinceEpoch;
                        bonusCanReward = false;

                        rewardGems(1);
                        setState(() {});
                      }
                    : null,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Share Champion Of The Day'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Share to get free gems everyday'),
                  championDayCanReward
                      ? const SizedBox()
                      : Countdown(
                          seconds: championDayNextReward
                              .difference(DateTime.now().toUtc())
                              .inSeconds,
                          build: (BuildContext context, double time) {
                            return buildTime(time);
                          },
                          onFinished: () {
                            setState(() => championDayCanReward = true);
                          },
                        ),
                ],
              ),
              leading: const FaIcon(FontAwesomeIcons.trophy),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: const Size(75, 40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'GET',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '2 ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 12.5,
                        ),
                      ],
                    ),
                  ],
                ),
                onPressed: championDayCanReward &&
                        DatabaseService().dayChampionShared
                    ? () {
                        championDayNextReward =
                            DateTime.now().toUtc().add(const Duration(days: 1));
                        championDayCanReward = false;

                        DatabaseService().championDayNextReward =
                            championDayNextReward.millisecondsSinceEpoch;
                        DatabaseService().dayChampionShared = false;

                        rewardGems(2);
                        setState(() {});
                      }
                    : null,
              ),
              onTap: () {
                showChampions('day');
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Share Champion Of The Week'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Share to get free gems every week'),
                  championWeekCanReward
                      ? const SizedBox()
                      : Countdown(
                          seconds: championWeekNextReward
                              .difference(DateTime.now().toUtc())
                              .inSeconds,
                          build: (BuildContext context, double time) {
                            return buildTime(time);
                          },
                          onFinished: () {
                            setState(() => championWeekCanReward = true);
                          },
                        ),
                ],
              ),
              leading: const FaIcon(FontAwesomeIcons.trophy),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: const Size(75, 40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'GET',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '3 ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 12.5,
                        ),
                      ],
                    ),
                  ],
                ),
                onPressed: championWeekCanReward &&
                        DatabaseService().weekChampionShared
                    ? () {
                        championWeekNextReward =
                            DateTime.now().toUtc().add(const Duration(days: 7));
                        championWeekCanReward = false;

                        DatabaseService().championWeekNextReward =
                            championWeekNextReward.millisecondsSinceEpoch;
                        DatabaseService().weekChampionShared = false;

                        rewardGems(3);
                        setState(() {});
                      }
                    : null,
              ),
              onTap: () {
                showChampions('week');
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Share Champion Of The Month'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Share to get free gems every month'),
                  championMonthCanReward
                      ? const SizedBox()
                      : Countdown(
                          seconds: championMonthNextReward
                              .difference(DateTime.now().toUtc())
                              .inSeconds,
                          build: (BuildContext context, double time) {
                            return buildTime(time);
                          },
                          onFinished: () {
                            setState(() => championMonthCanReward = true);
                          },
                        ),
                ],
              ),
              leading: const FaIcon(FontAwesomeIcons.trophy),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: const Size(75, 40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'GET',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '5 ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 12.5,
                        ),
                      ],
                    ),
                  ],
                ),
                onPressed: championMonthCanReward &&
                        DatabaseService().monthChampionShared
                    ? () {
                        championMonthNextReward = DateTime.now()
                            .toUtc()
                            .add(const Duration(days: 30));
                        championMonthCanReward = false;

                        DatabaseService().championMonthNextReward =
                            championMonthNextReward.millisecondsSinceEpoch;
                        DatabaseService().monthChampionShared = false;

                        rewardGems(5);
                        setState(() {});
                      }
                    : null,
              ),
              onTap: () {
                showChampions('month');
              },
            ),
          ],
        ),
      ),
    );
  }
}
