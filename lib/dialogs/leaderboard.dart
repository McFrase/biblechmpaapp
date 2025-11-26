import 'dart:io';

import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Leaderboard extends StatefulWidget {
  final String type;

  const Leaderboard(this.type, {Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard>
    with SingleTickerProviderStateMixin {
  Map leaderboard = {};
  TabController? _tabController;

  List<Tab> tabs = [
    const Tab(text: 'DAILY'),
    const Tab(text: 'WEEKLY'),
    const Tab(text: 'MONTHLY'),
    const Tab(text: 'YEARLY'),
    const Tab(text: 'ALL'),
  ];

  void prepare(period) {
    if (!canRefresh(period)) {
      leaderboard[period] =
          DatabaseService().restoreLeaderboard(widget.type, period);
    }
  }

  bool canRefresh(period) {
    DateTime nextRefreshTime = DateTime.fromMillisecondsSinceEpoch(
            DatabaseService().getRefreshTime(widget.type, period)!)
        .toUtc();
    return DateTime.now().toUtc().isAfter(nextRefreshTime);
  }

  String getMode(index) {
    switch (index) {
      case 0:
        return 'day';
      case 1:
        return 'week';
      case 2:
        return 'month';
      case 3:
        return 'year';
      case 4:
        return 'all';
      default:
        return 'all';
    }
  }

  void getLeaderboard() async {
    String period = getMode(_tabController!.index);

    if (leaderboard[period] == null) {
      String idToken = await AuthService().currentUser!.getIdToken();

      await Dio()
          .get(
        '${DatabaseService().apiUrl}/leaderboard/top/${widget.type}/$period',
        options: Options(
          headers: {
            'authorization': 'Bearer $idToken',
          },
        ),
      )
          .then((Response response) {
        if (response.data['status'] == 'success') {
          leaderboard[period] = {
            'data': response.data['data'],
            'rank': response.data['rank']
          };

          DatabaseService()
              .backupLeaderboard(widget.type, period, leaderboard[period]);
          DatabaseService().setRefreshTime(
              widget.type,
              period,
              DateTime.now()
                  .toUtc()
                  .add(Duration(
                      minutes: DatabaseService().getRefreshMinutes(period)!))
                  .millisecondsSinceEpoch);
        }
      });

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) getLeaderboard();
    });

    prepare('day');
    prepare('week');
    prepare('month');
    prepare('year');
    prepare('all');
    getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: 450,
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[900],
              tabs: tabs,
            ),
            body: TabBarView(
              controller: _tabController,
              children: List.generate(tabs.length, (int index) {
                String mode = getMode(index);

                return leaderboard[mode] == null
                    ? const SpinKitFadingCircle(
                        color: Colors.orange,
                        size: 50.0,
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(10.0),
                              children: leaderboard[mode]['data']
                                  .asMap()
                                  .entries
                                  .map<Row>((entry) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 32.5,
                                      child: Text(
                                        '#${entry.key + 1}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Image.file(
                                      File(
                                          "${DatabaseService().downloadPath}/images/avatar-${DatabaseService().validateAvatar(entry.value['avatar'])}.png"),
                                      height: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            entry.value['username'] ??
                                                '(DELETED ACCOUNT)',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: entry.value['username'] !=
                                                      null
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (entry.value['username'] != null)
                                            Image.asset(
                                              "icons/flags/png/${(entry.value['countrycode'] ?? '').toLowerCase()}.png",
                                              width: 25,
                                              package: 'country_icons',
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      entry.value['points'].toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          leaderboard[mode]['rank'] == null
                              ? const SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '#${leaderboard[mode]['rank']['position']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${leaderboard[mode]['rank']['points']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'YOU',
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 22.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        ],
                      );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
