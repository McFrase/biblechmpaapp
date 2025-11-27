import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Missions extends StatefulWidget {
  final String type;

  const Missions(this.type, {Key? key}) : super(key: key);

  @override
  _MissionsState createState() => _MissionsState();
}

class _MissionsState extends State<Missions> {
  double calculatePercentage() {
    double accumulate = 0;

    DatabaseService().missions[widget.type].forEach((value) {
      int full = value['count'] * DatabaseService().getMultiplier(widget.type);
      int rem = DatabaseService().getMissionData(widget.type, value['type'])!;
      accumulate += (full - rem) / full;
    });

    return accumulate / DatabaseService().missions[widget.type].length;
  }

  List<Widget> buildMissions() {
    return DatabaseService().missions[widget.type]!.map<Widget>((value) {
      bool pending =
          DatabaseService().getMissionData(widget.type, value['type'])! > 0;

      return Card(
        child: ListTile(
          enabled: pending,
          leading: FaIcon(
            value['icon'],
            size: 30,
          ),
          title: Text(
            value['mission'].replaceAll(
              '|<>|',
              "${value['count'] * DatabaseService().getMultiplier(widget.type)}",
            ),
          ),
          subtitle: pending
              ? Text(
                  "${DatabaseService().getMissionData(widget.type, value['type'])} more to go")
              : const Text('Completed'),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              fixedSize: const Size(75, 40),
            ),
            onPressed: pending ? () => buttonOnPressed(value) : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SKIP',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${DatabaseService().getMultiplier(widget.type)! * 3} ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const FaIcon(
                      FontAwesomeIcons.gem,
                      color: Colors.white,
                      size: 12.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void buttonOnPressed(value) async {
    if (DatabaseService().gems! >=
        DatabaseService().getMultiplier(widget.type)! * 3) {
      UiService().showAlert(
        context,
        title: 'Skip Mission?',
        desc:
            'This would cost ${DatabaseService().getMultiplier(widget.type)! * 3} Gem(s). Proceed?',
        isWarning: true,
        hasCancelButton: true,
        cancelButtonText: 'NO',
        buttonText: 'YES',
        onClick: () async {
          AudioService().playChime();
          DatabaseService().gems = DatabaseService().gems! -
              (3 * DatabaseService().getMultiplier(widget.type)!);
          if (value['type'] != 'usegems') {
            await DatabaseService().updateMissions(widget.type, 'usegems',
                3 * DatabaseService().getMultiplier(widget.type)!);
          }

          await DatabaseService().updateMissions(
            widget.type,
            value['type'],
            value['count'] * DatabaseService().getMultiplier(widget.type),
          );

          setState(() {});
        },
      );
    } else {
      UiService().showAlert(
        context,
        isError: true,
        title: 'Insufficient Gems',
        desc:
            'You have less than ${DatabaseService().getMultiplier(widget.type)! * 3} Gem(s). Try again later!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missions',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Text(
                      'Current Multiplier: x${DatabaseService().getMultiplier(widget.type)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      'Gems: ${DatabaseService().gems}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    const SizedBox(width: 142.5, height: 62.5),
                    Positioned(
                      bottom: 0,
                      right: 17.5,
                      child: LinearPercentIndicator(
                        width: 100.0,
                        animation: false,
                        lineHeight: 10.0,
                        percent: calculatePercentage(),
                        barRadius: const Radius.circular(10),
                        progressColor: Colors.green,
                      ),
                    ),
                    Positioned(
                      left: 80,
                      bottom: 4.5,
                      child: Badge(
                        badgeContent: const Padding(
                          padding: EdgeInsets.all(2.5),
                          child: Text(
                            '+1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        badgeColor: Colors.orange,
                        toAnimate: true,
                        position: BadgePosition.bottomEnd(),
                        child: Image.file(
                          File(
                              '${DatabaseService().downloadPath}/images/multiplier.png'),
                          width: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 0,
                ),
                children: buildMissions(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
