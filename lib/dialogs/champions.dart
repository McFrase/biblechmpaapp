import 'dart:io';
import 'dart:typed_data';

import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Champions extends StatefulWidget {
  final String mode;

  const Champions(this.mode, {Key? key}) : super(key: key);

  @override
  _ChampionsState createState() => _ChampionsState();
}

class _ChampionsState extends State<Champions> {
  String text = '';
  String date = '???';
  String championText = '';
  String preschoolUsername = '???';
  String preteensUsername = '???';
  String? preschoolCountryCode;
  String? preteensCountryCode;
  Widget preschoolCountry = const Text('???');
  Widget preteensCountry = const Text('???');
  int timestamp = DatabaseService().champions?['timestamp'] ?? 0;
  int? preschoolAvatar;
  int? preteensAvatar;
  Map? bounds;
  Map? champions;
  Image? image;

  ScreenshotController screenshotController = ScreenshotController();

  void shareScreenshot() {
    screenshotController
        .capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    )
        .then((Uint8List? image) {
      File file = File(
          '${DatabaseService().temporaryPath}/${DateTime.now().millisecondsSinceEpoch}.png');
      file.writeAsBytesSync(image!);

      Share.shareFiles(
        [file.path],
        mimeTypes: ['image/png'],
        subject: 'Bible Champs',
        text:
            "$text $championText Download the Bible Champs application now. Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child. \n${DatabaseService().dynamicUrl}",
      );

      if (widget.mode == 'day') DatabaseService().dayChampionShared = true;
      if (widget.mode == 'week') DatabaseService().weekChampionShared = true;
      if (widget.mode == 'month') DatabaseService().monthChampionShared = true;
    });
  }

  @override
  void initState() {
    super.initState();
    bounds = DatabaseService().championBounds[widget.mode];
    champions = DatabaseService().champions?[widget.mode];

    if (DatabaseService().champions?[widget.mode] != null) {
      if (widget.mode == 'day') {
        DateTime dayDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc();
        dayDate = dayDate.subtract(const Duration(days: 1));
        date = DateFormat.yMMMMd().format(dayDate);
        text = 'Bible Champs Top Champions from yesterday.';
      } else if (widget.mode == 'week') {
        DateTime weekDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc();

        weekDate = weekDate.subtract(Duration(
          days: weekDate.weekday - DateTime.monday,
        ));

        date =
            "Week ${(int.parse(DateFormat('D').format(weekDate)) / 7).floor() + 1}, ${weekDate.year}";
        text = 'Bible Champs Top Champions from last week.';
      } else if (widget.mode == 'month') {
        DateTime monthDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc();
        monthDate = monthDate.subtract(const Duration(days: 30));
        date = DateFormat('MMMM, y').format(monthDate);
        text = 'Bible Champs Top Champions from last month.';
      }

      if (champions!['preschool'] != null) {
        preschoolAvatar = champions!['preschool']['avatar'];
        preschoolUsername = champions!['preschool']['username'];
        preschoolCountryCode = champions!['preschool']['countrycode'];
        championText =
            'We have $preschoolUsername ($preschoolCountryCode) our Preschool Champ.';

        preschoolCountry = Image.asset(
          'icons/flags/png/${preschoolCountryCode!.toLowerCase()}.png',
          height: bounds!['preschool-country-icon-height'],
          package: 'country_icons',
        );
      }

      if (champions!['preteens'] != null) {
        preteensAvatar = champions!['preteens']['avatar'];
        preteensUsername = champions!['preteens']['username'];
        preteensCountryCode = champions!['preteens']['countrycode'];
        championText =
            'We have $preteensUsername ($preteensCountryCode) our Preteens Champ.';

        preteensCountry = Image.asset(
          'icons/flags/png/${preteensCountryCode!.toLowerCase()}.png',
          height: bounds!['preteens-country-icon-height'],
          package: 'country_icons',
        );
      }

      if (champions!['preschool'] != null && champions!['preteens'] != null) {
        championText =
            'We have $preschoolUsername ($preschoolCountryCode) our Preschool Champ and $preteensUsername ($preteensCountryCode) our Preteens Champ.';
      }
    }

    Fluttertoast.showToast(
      msg: 'Tap to share',
      toastLength: Toast.LENGTH_LONG,
    );

    String fileName = DatabaseService()
        .championSettings!
        .firstWhere((value) => value['name'] == widget.mode)['image'];

    image = Image.file(
      File('${DatabaseService().downloadPath}/champions/$fileName'),
      width: bounds!['width'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => shareScreenshot(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            width: bounds!['width'],
            height: bounds!['height'],
            child: Stack(
              children: [
                Positioned(
                  left: bounds!['preschool-avatar-left'],
                  top: bounds!['preschool-avatar-top'],
                  child: Image.file(
                    File(
                        '${DatabaseService().downloadPath}/images/avatar-${DatabaseService().validateAvatar(preschoolAvatar)}.png'),
                    width: bounds!['preschool-avatar-width'],
                  ),
                ),
                Positioned(
                  right: bounds!['preteens-avatar-right'],
                  top: bounds!['preteens-avatar-top'],
                  child: Image.file(
                    File(
                        '${DatabaseService().downloadPath}/images/avatar-${DatabaseService().validateAvatar(preteensAvatar)}.png'),
                    width: bounds!['preteens-avatar-width'],
                  ),
                ),
                image ?? const SizedBox(),
                Positioned(
                  left: bounds!['preschool-country-left'],
                  top: bounds!['preschool-country-top'],
                  child: Container(
                    alignment: Alignment.center,
                    width: bounds!['preschool-country-box-width'],
                    height: bounds!['preschool-country-box-height'],
                    child: preschoolCountry,
                  ),
                ),
                Positioned(
                  right: bounds!['preteens-country-right'],
                  top: bounds!['preteens-country-top'],
                  child: Container(
                    alignment: Alignment.center,
                    width: bounds!['preteens-country-box-width'],
                    height: bounds!['preteens-country-box-height'],
                    child: preteensCountry,
                  ),
                ),
                Positioned(
                  left: bounds!['preschool-username-left'],
                  top: bounds!['preschool-username-top'],
                  child: Container(
                    width: bounds!['preschool-username-box-width'],
                    alignment: Alignment.center,
                    child: Text(
                      preschoolUsername,
                      style: TextStyle(
                        color: bounds!['preschool-username-text-color'],
                        fontSize: bounds!['preschool-username-text-size'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: bounds!['preteens-username-right'],
                  top: bounds!['preteens-username-top'],
                  child: Container(
                    width: bounds!['preteens-username-box-width'],
                    alignment: Alignment.center,
                    child: Text(
                      preteensUsername,
                      style: TextStyle(
                        color: bounds!['preteens-username-text-color'],
                        fontSize: bounds!['preteens-username-text-size'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: bounds!['date-left'],
                  top: bounds!['date-top'],
                  child: Container(
                    width: bounds!['date-box-width'],
                    alignment: Alignment.center,
                    child: Text(
                      date,
                      style: TextStyle(
                        color: bounds!['date-text-color'],
                        fontSize: bounds!['date-text-size'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
