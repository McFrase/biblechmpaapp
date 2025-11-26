import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:biblechamps/services/auth.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static String? _galleryPath;
  static String? _downloadPath;
  static String? _temporaryPath;
  static LocalStorage? _appData;
  static bool launchUrl = false;
  static PackageInfo? _packageInfo;
  static SharedPreferences? _preferences;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Map missions = {
    'preschool': [
      {
        'type': 'getgems',
        'mission': 'Get |<>| Gems',
        'icon': FontAwesomeIcons.gem,
        'count': 3
      },
      {
        'type': 'usegems',
        'mission': 'Use |<>| Gems',
        'icon': FontAwesomeIcons.gem,
        'count': 3
      },
      {
        'type': 'gettripplestars',
        'mission': 'Get Tripple Stars x|<>|',
        'icon': FontAwesomeIcons.star,
        'count': 1
      },
      {
        'type': 'levelup',
        'mission': 'Level Up x|<>|',
        'icon': FontAwesomeIcons.levelUpAlt,
        'count': 1
      },
      {
        'type': 'namethepicture',
        'mission': 'Correctly Answer Name The Picture |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'fillinthegaps',
        'mission': 'Correctly Answer Fill In The Gaps |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'jigsawpuzzle',
        'mission': 'Correctly Answer jigsaw Puzzle |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'spotthedifferences',
        'mission': 'Correctly Answer Spot The Differences |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'trickymaze',
        'mission': 'Correctly Answer Tricky Maze |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
    ],
    'preteens': [
      {
        'type': 'getgems',
        'mission': 'Get |<>| Gems',
        'icon': FontAwesomeIcons.gem,
        'count': 3
      },
      {
        'type': 'usegems',
        'mission': 'Use |<>| Gems',
        'icon': FontAwesomeIcons.gem,
        'count': 3
      },
      {
        'type': 'gettripplestars',
        'mission': 'Get Tripple Stars x|<>|',
        'icon': FontAwesomeIcons.star,
        'count': 1
      },
      {
        'type': 'levelup',
        'mission': 'Level Up x|<>|',
        'icon': FontAwesomeIcons.levelUpAlt,
        'count': 1
      },
      {
        'type': 'biblequiz',
        'mission': 'Correctly Answer Bible Quiz |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'fillinthegaps',
        'mission': 'Correctly Answer Fill In The Gaps |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 4
      },
      {
        'type': 'namethebook',
        'mission': 'Correctly Answer Name The Book |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'trueorfalse',
        'mission': 'Correctly Answer True Or False |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'whosaidthat',
        'mission': 'Correctly Answer Who Said That |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 10
      },
      {
        'type': 'wordsearch',
        'mission': 'Correctly Answer Word Search |<>| Times',
        'icon': FontAwesomeIcons.trophy,
        'count': 4
      }
    ],
  };

  final Map celebrationBounds = {
    'birthday1': {
      'title': 'Happy Birthday 1',
      'icon': FontAwesomeIcons.birthdayCake,
      'width': 280.0,
      'height': 280.0,
      'inner-radius': 120.0,
      'text-width': 280.0,
      'text-height': 26.0,
      'text-distance-left': 0.0,
      'text-distance-top': 226.0,
      'inner-distance-left': 75.0,
      'inner-distance-top': 60.5,
      'editor-distance-left': -10.0,
      'editor-distance-top': -25.0,
    },
    'birthday2': {
      'title': 'Happy Birthday 2',
      'icon': FontAwesomeIcons.birthdayCake,
      'width': 280.0,
      'height': 280.0,
      'inner-radius': 140.0,
      'text-width': 280.0,
      'text-height': 26.0,
      'text-distance-left': 0.0,
      'text-distance-top': 226.0,
      'inner-distance-left': 65.0,
      'inner-distance-top': 65.0,
      'editor-distance-left': -10.0,
      'editor-distance-top': -10.0,
    },
    'childrensday': {
      'title': "Happy Children's Day",
      'icon': FontAwesomeIcons.child,
      'width': 315.0,
      'height': 280.0,
      'inner-radius': 120.0,
      'text-width': 160.0,
      'text-height': 26.0,
      'text-distance-left': 78.0,
      'text-distance-top': 229.0,
      'inner-distance-left': 90.0,
      'inner-distance-top': 70.0,
      'editor-distance-left': 5.0,
      'editor-distance-top': -15.0,
    },
    'easter': {
      'title': 'Happy Easter',
      'icon': FontAwesomeIcons.cross,
      'width': 315.0,
      'height': 280.0,
      'inner-radius': 93.0,
      'text-width': 185.0,
      'text-height': 24.0,
      'text-distance-left': 118.0,
      'text-distance-top': 228.0,
      'inner-distance-left': 161.0,
      'inner-distance-top': 105.5,
      'editor-distance-left': 63.0,
      'editor-distance-top': 7.0,
    },
    'newyear': {
      'title': 'Happy New Year',
      'icon': FontAwesomeIcons.glassCheers,
      'width': 280.0,
      'height': 280.0,
      'inner-radius': 120.0,
      'text-width': 180.0,
      'text-height': 24.0,
      'text-distance-left': 50.0,
      'text-distance-top': 235.0,
      'inner-distance-left': 74.0,
      'inner-distance-top': 74.0,
      'editor-distance-left': -10.0,
      'editor-distance-top': -10.0,
    },
    'thanksgiving': {
      'title': 'Happy Thanksgiving',
      'icon': FontAwesomeIcons.prayingHands,
      'width': 420.0,
      'height': 280.0,
      'inner-radius': 120.0,
      'text-width': 176.5,
      'text-height': 30.0,
      'text-distance-left': 227.0,
      'text-distance-top': 180.0,
      'inner-distance-left': 50.0,
      'inner-distance-top': 80.0,
      'editor-distance-left': -35.0,
      'editor-distance-top': -4.0,
    },
    'christmas': {
      'title': 'Merry Christmas',
      'icon': FontAwesomeIcons.tree,
      'width': 315.0,
      'height': 280.0,
      'inner-radius': 130.0,
      'text-width': 160.0,
      'text-height': 24.0,
      'text-distance-left': 140.0,
      'text-distance-top': 236.0,
      'inner-distance-left': 153.0,
      'inner-distance-top': 100.0,
      'editor-distance-left': 73.0,
      'editor-distance-top': 20.0,
    },
  };

  final Map championBounds = {
    'day': {
      'width': 500.0,
      'height': 278.0,
      'preschool-avatar-top': 90.0,
      'preschool-avatar-left': 14.0,
      'preschool-avatar-width': 100.0,
      'preteens-avatar-top': 90.0,
      'preteens-avatar-right': 15.0,
      'preteens-avatar-width': 100.0,
      'preschool-country-top': 196.0,
      'preschool-country-left': 45.0,
      'preschool-country-box-width': 48.0,
      'preschool-country-box-height': 23.0,
      'preschool-country-icon-height': 18.0,
      'preteens-country-top': 196.0,
      'preteens-country-right': 39.0,
      'preteens-country-box-width': 48.0,
      'preteens-country-box-height': 23.0,
      'preteens-country-icon-height': 18.0,
      'preschool-username-top': 172.0,
      'preschool-username-left': 10.0,
      'preschool-username-box-width': 112.5,
      'preschool-username-text-size': 16.0,
      'preschool-username-text-color': Colors.blue[900],
      'preteens-username-top': 172.0,
      'preteens-username-right': 10.0,
      'preteens-username-box-width': 112.5,
      'preteens-username-text-size': 16.0,
      'preteens-username-text-color': Colors.blue[900],
      'date-top': 258.0,
      'date-left': 209.5,
      'date-box-width': 89.0,
      'date-text-size': 11.0,
      'date-text-color': Colors.white,
    },
    'week': {
      'width': 311.0,
      'height': 280.0,
      'preschool-avatar-top': 62.0,
      'preschool-avatar-left': 200.0,
      'preschool-avatar-width': 70.0,
      'preteens-avatar-top': 185.0,
      'preteens-avatar-right': 39.5,
      'preteens-avatar-width': 70.0,
      'preschool-country-top': 132.0,
      'preschool-country-left': 223.0,
      'preschool-country-box-width': 32.0,
      'preschool-country-box-height': 15.0,
      'preschool-country-icon-height': 12.0,
      'preteens-country-top': 254.5,
      'preteens-country-right': 55.5,
      'preteens-country-box-width': 32.0,
      'preteens-country-box-height': 15.0,
      'preteens-country-icon-height': 12.0,
      'preschool-username-top': 116.0,
      'preschool-username-left': 204.0,
      'preschool-username-box-width': 70.0,
      'preschool-username-text-size': 12.0,
      'preschool-username-text-color': Colors.blue[900],
      'preteens-username-top': 238.25,
      'preteens-username-right': 37.0,
      'preteens-username-box-width': 70.0,
      'preteens-username-text-size': 12.0,
      'preteens-username-text-color': Colors.blue[900],
      'date-top': 193.0,
      'date-left': 112.75,
      'date-box-width': 70.0,
      'date-text-size': 10.0,
      'date-text-color': Colors.blue[900],
    },
    'month': {
      'width': 350.0,
      'height': 280.0,
      'preschool-avatar-top': 95.0,
      'preschool-avatar-left': 5.0,
      'preschool-avatar-width': 105.0,
      'preteens-avatar-top': 95.0,
      'preteens-avatar-right': 5.0,
      'preteens-avatar-width': 105.0,
      'preschool-country-top': 196.0,
      'preschool-country-left': 41.0,
      'preschool-country-box-width': 30.0,
      'preschool-country-box-height': 10.0,
      'preschool-country-icon-height': 8.5,
      'preteens-country-top': 196.0,
      'preteens-country-right': 41.0,
      'preteens-country-box-width': 30.0,
      'preteens-country-box-height': 10.0,
      'preteens-country-icon-height': 8.5,
      'preschool-username-top': 177.5,
      'preschool-username-left': 22.5,
      'preschool-username-box-width': 70.0,
      'preschool-username-text-size': 14.0,
      'preschool-username-text-color': Colors.blue[900],
      'preteens-username-top': 177.5,
      'preteens-username-right': 22.5,
      'preteens-username-box-width': 70.0,
      'preteens-username-text-size': 14.0,
      'preteens-username-text-color': Colors.blue[900],
      'date-top': 260.75,
      'date-left': 135.0,
      'date-box-width': 80.0,
      'date-text-size': 11.0,
      'date-text-color': Colors.blue[900],
    },
  };

  String get androidVersion => _packageInfo!.version;

  String? get androidVersionUpdate => _preferences!.getString('androidversion');

  int get androidVersionId => int.parse(_packageInfo!.buildNumber);

  int? get androidVersionIdUpdate => _preferences!.getInt('androidversionid');

  int? get androidUpdateTime => _preferences!.getInt('androidupdatetime');

  String get galleryPath => _galleryPath!;

  String get downloadPath => _downloadPath!;

  String get temporaryPath => _temporaryPath!;

  String get uid => AuthService().currentUser!.uid;

  String? get email => AuthService().currentUser!.email;

  String get apiUrl => 'https://reg.loveworldchildrensministry.org/api';

  String? get uploadUrl => _preferences!.getString('uploadurl');

  String? get policyUrl => _preferences!.getString('policyurl');

  String? get dynamicUrl => _preferences!.getString('dynamicurl');

  String? get resourceUrl => _preferences!.getString('resourceurl');

  String? get username => _preferences!.getString('username');

  String? get firstname => _preferences!.getString('firstname');

  String? get lastname => _preferences!.getString('lastname');

  String? get country => _preferences!.getString('country');

  String? get countryCode => _preferences!.getString('countrycode');

  String? get state => _preferences!.getString('state');

  String? get memoryVerseType => _preferences!.getString('memoryversetype');

  int? get gems => _preferences!.getInt('gems');

  int? get avatar => _preferences!.getInt('avatar');

  int? get hasPrayed => _preferences!.getInt('hasprayed');

  int? get lastVisit => _preferences!.getInt('lastvisit');

  int get lastValidated =>
      json.decode(File('${DatabaseService().downloadPath}/lastvalidated.json')
          .readAsStringSync());

  int? get bonusNextReward => _preferences!.getInt('bonusnextreward');

  int? get memoryVerseIndex => _preferences!.getInt('memoryverseindex');

  int? get championDayNextReward =>
      _preferences!.getInt('championdaynextreward');

  int? get championWeekNextReward =>
      _preferences!.getInt('championweeknextreward');

  int? get championMonthNextReward =>
      _preferences!.getInt('championmonthnextreward');

  List? get faqs => _appData!.getItem('faqs');

  List? get videos => _appData!.getItem('videos');

  List? get songs => _appData!.getItem('songs');

  List? get stories => _appData!.getItem('stories');

  List? get collections => _appData!.getItem('collections');

  List? get didYouKnow => _appData!.getItem('didyouknow');

  List? get wordOfTheDay => _appData!.getItem('wordoftheday');

  List? get dailyAffirmations => _appData!.getItem('dailyaffirmations');

  List? get gamePictures => _appData!.getItem('gamepictures')..shuffle();

  List? get championSettings => _appData!.getItem('championsettings');

  List? get celebrationSettings => _appData!.getItem('celebrationsettings');

  List? get preschoolMemoryVerses =>
      _appData!.getItem('memoryverses-preschool');

  List? get preteensMemoryVerses =>
      _appData!.getItem('memoryverses-preteens')..shuffle();

  Map? get champions => _appData!.getItem('champions');

  bool get fullyLoggedIn => _preferences!.getBool('fullyloggedin') ?? false;

  bool get dayChampionShown =>
      _preferences!.getBool('daychampionshown') ?? false;

  bool get weekChampionShown =>
      _preferences!.getBool('weekchampionshown') ?? false;

  bool get monthChampionShown =>
      _preferences!.getBool('monthchampionshown') ?? false;

  bool get dayChampionShared =>
      _preferences!.getBool('daychampionshared') ?? false;

  bool get weekChampionShared =>
      _preferences!.getBool('weekchampionshared') ?? false;

  bool get monthChampionShared =>
      _preferences!.getBool('monthchampionshared') ?? false;

  set fullyLoggedIn(bool value) =>
      _preferences!.setBool('fullyloggedin', value);

  set dayChampionShown(bool value) =>
      _preferences!.setBool('daychampionshown', value);

  set weekChampionShown(bool value) =>
      _preferences!.setBool('weekchampionshown', value);

  set monthChampionShown(bool value) =>
      _preferences!.setBool('monthchampionshown', value);

  set dayChampionShared(bool value) =>
      _preferences!.setBool('daychampionshared', value);

  set weekChampionShared(bool value) =>
      _preferences!.setBool('weekchampionshared', value);

  set monthChampionShared(bool value) =>
      _preferences!.setBool('monthchampionshared', value);

  set hasPrayed(int? value) {
    _preferences!.setInt('hasprayed', value!);

    syncUserData(Map.from({
      'hasprayed': value,
    }));
  }

  set gems(int? value) {
    _preferences!.setInt('gems', value!);

    syncUserData(Map.from({
      'gems': value,
    }));
  }

  set bonusNextReward(int? value) {
    _preferences!.setInt('bonusnextreward', value!);

    syncUserData(Map.from({
      'bonusnextreward': value,
    }));
  }

  set championDayNextReward(int? value) {
    _preferences!.setInt('championdaynextreward', value!);

    syncUserData(Map.from({
      'championdaynextreward': value,
    }));
  }

  set championWeekNextReward(int? value) {
    _preferences!.setInt('championweeknextreward', value!);

    syncUserData(Map.from({
      'championweeknextreward': value,
    }));
  }

  set championMonthNextReward(int? value) {
    _preferences!.setInt('championmonthnextreward', value!);

    syncUserData(Map.from({
      'championmonthnextreward': value,
    }));
  }

  int? getLevel(game) => _preferences!.getInt('$game-level');

  int? getScore(game) => _preferences!.getInt('$game-score');

  int? getBest(game) => _preferences!.getInt('$game-best');

  int? getMultiplier(type) => _preferences!.getInt('multiplier-$type');

  int? getMissionData(type, data) =>
      _preferences!.getInt('missions-$type-$data');

  int? getRefreshTime(type, period) =>
      _preferences!.getInt('leaderboard-refresh-$type-$period') ?? 0;

  int? getRefreshMinutes(period) =>
      _preferences!.getInt('leaderboard-refresh-minutes-$period') ?? 0;

  int randomBetween(min, max) => (max > min)
      ? min + Random().nextInt(max - min)
      : min; //would generate values between min and max-1

  Map? restoreLeaderboard(type, period) =>
      _appData!.getItem('leaderboard-$type-$period');

  List? getGameData(type, data) => _appData!.getItem('$type-$data')?..shuffle();

  double? getVolume(type) => _preferences!.getDouble('volume-$type');

  Future setAvatar(int value) async =>
      await _preferences!.setInt('avatar', value);

  Future setUsername(String value) async =>
      await _preferences!.setString('username', value);

  Future setFirstname(String value) async =>
      await _preferences!.setString('firstname', value);

  Future setLastname(String value) async =>
      await _preferences!.setString('lastname', value);

  Future setCountry(String value) async =>
      await _preferences!.setString('country', value);

  Future setCountrycode(String value) async =>
      await _preferences!.setString('countrycode', value);

  Future setState(String value) async =>
      await _preferences!.setString('state', value);

  void setVolume(type, double volume) =>
      _preferences!.setDouble('volume-$type', volume);

  void setRefreshTime(type, period, time) =>
      _preferences!.setInt('leaderboard-refresh-$type-$period', time);

  void backupLeaderboard(type, period, leaderboard) =>
      _appData!.setItem('leaderboard-$type-$period', leaderboard);

  Future databaseInit() async {
    String documentsDirectory = (await getApplicationDocumentsDirectory()).path;

    _packageInfo = await PackageInfo.fromPlatform();
    _preferences = await SharedPreferences.getInstance();
    _galleryPath = '$documentsDirectory/gallery';
    _downloadPath = '$documentsDirectory/download';
    _temporaryPath = (await getTemporaryDirectory()).path;

    _appData = LocalStorage('app');
    await _appData!.ready;
  }

  Future<Response> syncUserData(Map data) async {
    String idToken = await AuthService().currentUser!.getIdToken();

    Response response = await Dio().put(
      '$apiUrl/user',
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      ),
      data: data,
    );

    return response;
  }

  void memoryVerseMemorize(type, index) {
    if (type == 'preschool') _preferences!.setInt('memoryverseindex', index);
    _preferences!.setString('memoryversetype', type);
  }

  Future depleteMultiplier() async {
    multiplierFix('preschool');
    multiplierFix('preteens');

    DateTime now = DateTime.now().toUtc();
    DateTime past = DateTime.fromMillisecondsSinceEpoch(lastVisit!).toUtc();
    int weeks = (now.difference(past).inDays / 7).floor();

    if (weeks > 0) {
      await _preferences!.setInt(
          'multiplier-preschool',
          (getMultiplier('preschool')! > weeks)
              ? getMultiplier('preschool')! - weeks
              : 1);

      await _preferences!.setInt(
          'multiplier-preteens',
          (getMultiplier('preteens')! > weeks)
              ? getMultiplier('preteens')! - weeks
              : 1);

      refreshMissions('preschool');
      refreshMissions('preteens');
    }

    await _preferences!.setInt('lastvisit', now.millisecondsSinceEpoch);
  }

  //fix negavive accumulation bug on some (older) user's data. BUG FIX! DO NOT DELETE!!
  void multiplierFix(type) {
    bool shouldRefresh = false;

    missions[type].forEach((value) {
      int full = value['count'] * getMultiplier(type);
      int rem = getMissionData(type, value['type'])!;

      if (full < rem) shouldRefresh = true;
    });

    if (shouldRefresh) refreshMissions(type);
  }

  Future updateMissions(String type, String data, int value) async {
    if (getMissionData(type, data) == 0) return null;

    Map? missionInfo;
    Map? returnData;

    await _preferences!.setInt(
        'missions-$type-$data',
        getMissionData(type, data)! <= value
            ? 0
            : getMissionData(type, data)! - value);

    if (getMissionData(type, data) == 0) {
      missionInfo = missions[type].firstWhere((value) => data == value['type']);

      returnData = {
        'mission': missionInfo!['mission'].replaceAll(
            '|<>|', '${missionInfo['count'] * getMultiplier(type)}'),
        'icon': missionInfo['icon']
      };
    }

    await completeMissions(type);

    if (missionInfo != null) return returnData;
    return null;
  }

  void syncMissions(type) {
    Map data = {
      'multiplier$type': getMultiplier(type),
      'missions${type}getgems': getMissionData(type, 'getgems'),
      'missions${type}usegems': getMissionData(type, 'usegems'),
      'missions${type}gettripplestars': getMissionData(type, 'gettripplestars'),
      'missions${type}levelup': getMissionData(type, 'levelup'),
    };

    if (type == 'preschool') {
      data.addAll({
        'missionspreschoolnamethepicture':
            getMissionData(type, 'namethepicture'),
        'missionspreschoolfillinthegaps': getMissionData(type, 'fillinthegaps'),
        'missionspreschooljigsawpuzzle': getMissionData(type, 'jigsawpuzzle'),
        'missionspreschoolspotthedifferences':
            getMissionData(type, 'spotthedifferences'),
        'missionspreschooltrickymaze': getMissionData(type, 'trickymaze'),
      });
    }

    if (type == 'preteens') {
      data.addAll({
        'missionspreteensbiblequiz': getMissionData(type, 'biblequiz'),
        'missionspreteensfillinthegaps': getMissionData(type, 'fillinthegaps'),
        'missionspreteensnamethebook': getMissionData(type, 'namethebook'),
        'missionspreteenstrueorfalse': getMissionData(type, 'trueorfalse'),
        'missionspreteenswhosaidthat': getMissionData(type, 'whosaidthat'),
        'missionspreteenswordsearch': getMissionData(type, 'wordsearch'),
      });
    }

    syncUserData(data);
  }

  Future refreshMissions(type) async {
    if (type == 'preschool') {
      await _preferences!.setInt(
          'missions-preschool-getgems', 3 * getMultiplier('preschool')!);
      await _preferences!.setInt(
          'missions-preschool-usegems', 3 * getMultiplier('preschool')!);
      await _preferences!.setInt('missions-preschool-gettripplestars',
          1 * getMultiplier('preschool')!);
      await _preferences!.setInt(
          'missions-preschool-levelup', 1 * getMultiplier('preschool')!);
      await _preferences!.setInt('missions-preschool-namethepicture',
          10 * getMultiplier('preschool')!);
      await _preferences!.setInt(
          'missions-preschool-fillinthegaps', 10 * getMultiplier('preschool')!);
      await _preferences!.setInt(
          'missions-preschool-jigsawpuzzle', 10 * getMultiplier('preschool')!);
      await _preferences!.setInt('missions-preschool-spotthedifferences',
          10 * getMultiplier('preschool')!);
      await _preferences!.setInt(
          'missions-preschool-trickymaze', 10 * getMultiplier('preschool')!);

      syncMissions('preschool');
    }

    if (type == 'preteens') {
      await _preferences!.setInt(
        'missions-preteens-getgems',
        3 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-usegems',
        3 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-gettripplestars',
        1 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-levelup',
        1 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-biblequiz',
        10 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-fillinthegaps',
        4 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-namethebook',
        10 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-trueorfalse',
        10 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-whosaidthat',
        10 * getMultiplier('preteens')!,
      );

      await _preferences!.setInt(
        'missions-preteens-wordsearch',
        4 * getMultiplier('preteens')!,
      );

      syncMissions('preteens');
    }
  }

  Future completeMissions(type) async {
    if (type == 'preschool') {
      if (getMissionData('preschool', 'getgems') == 0 &&
          getMissionData('preschool', 'usegems') == 0 &&
          getMissionData('preschool', 'gettripplestars') == 0 &&
          getMissionData('preschool', 'levelup') == 0 &&
          getMissionData('preschool', 'namethepicture') == 0 &&
          getMissionData('preschool', 'fillinthegaps') == 0 &&
          getMissionData('preschool', 'jigsawpuzzle') == 0 &&
          getMissionData('preschool', 'spotthedifferences') == 0 &&
          getMissionData('preschool', 'trickymaze') == 0) {
        await _preferences!
            .setInt('multiplier-preschool', getMultiplier('preschool')! + 1);
        await refreshMissions('preschool');
      }
    } else if (type == 'preteens') {
      if (getMissionData('preteens', 'getgems') == 0 &&
          getMissionData('preteens', 'usegems') == 0 &&
          getMissionData('preteens', 'gettripplestars') == 0 &&
          getMissionData('preteens', 'levelup') == 0 &&
          getMissionData('preteens', 'biblequiz') == 0 &&
          getMissionData('preteens', 'fillinthegaps') == 0 &&
          getMissionData('preteens', 'namethebook') == 0 &&
          getMissionData('preteens', 'trueorfalse') == 0 &&
          getMissionData('preteens', 'whosaidthat') == 0 &&
          getMissionData('preteens', 'wordsearch') == 0) {
        await _preferences!
            .setInt('multiplier-preteens', getMultiplier('preteens')! + 1);
        await refreshMissions('preteens');
      }
    }
  }

  Future setGameData(game, level, score) async {
    await _preferences!.setInt('$game-level', level);
    await _preferences!.setInt('$game-score', score);

    syncUserData(Map.from({
      '${game.split('-')[0]}${game.split('-')[1]}level': level,
      '${game.split('-')[0]}${game.split('-')[1]}score': score,
    }));
  }

  Future setLeaderboardData(game, points) async {
    String idToken = await AuthService().currentUser!.getIdToken();
    String type = (game.indexOf('preteens') >= 0) ? 'preteens' : 'preschool';

    Dio().post(
      '$apiUrl/leaderboard/entries/add/$type',
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      ),
      data: {'points': '$points'},
    );
  }

  int validateAvatar(avatar) {
    // from assets
    List<int> avatars = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

    if (avatars.contains(avatar)) return avatar;

    return 0;
  }

  void setNewBest(game, best) {
    _preferences!.setInt(game + '-best', best);

    syncUserData(Map.from({
      '${game.split('-')[0]}${game.split('-')[1]}best': best,
    }));
  }

  bool isNewUser() =>
      username == '' ||
      firstname == '' ||
      lastname == '' ||
      country == '' ||
      countryCode == '' ||
      state == '';

  bool hasAndroidUpdate() => androidVersionIdUpdate! > androidVersionId;

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      if (!await Permission.storage.request().isGranted) return false;
    }

    Directory(galleryPath).create();
    Directory(downloadPath).create();
    Directory(temporaryPath).create();

    return true;
  }

  Future updateGameData(type, game, data) async {
    await _preferences!.setInt('$type-$game-level', data['$type${game}level']);
    await _preferences!.setInt('$type-$game-score', data['$type${game}score']);
    await _preferences!.setInt('$type-$game-best', data['$type${game}best']);
  }

  Future updateUserData(data) async {
    await _preferences!.setString('username', data['username'] ?? '');
    await _preferences!.setString('firstname', data['firstname'] ?? '');
    await _preferences!.setString('lastname', data['lastname'] ?? '');
    await _preferences!.setString('country', data['country'] ?? '');
    await _preferences!.setString('countrycode', data['countrycode'] ?? '');
    await _preferences!.setString('state', data['state'] ?? '');

    await _preferences!.setInt('gems', data['gems']);
    await _preferences!.setInt('hasprayed', data['hasprayed']);
    await _preferences!.setInt('avatar', data['avatar']);
    await _preferences!.setInt('bonusnextreward', data['bonusnextreward']);
    await _preferences!
        .setInt('championdaynextreward', data['championdaynextreward']);
    await _preferences!
        .setInt('championweeknextreward', data['championweeknextreward']);
    await _preferences!
        .setInt('championmonthnextreward', data['championmonthnextreward']);
    await _preferences!.setInt('lastvisit', data['lastvisit']);
    await _preferences!
        .setInt('missions-preschool-getgems', data['missionspreschoolgetgems']);
    await _preferences!
        .setInt('missions-preschool-usegems', data['missionspreschoolusegems']);
    await _preferences!.setInt('missions-preschool-gettripplestars',
        data['missionspreschoolgettripplestars']);
    await _preferences!
        .setInt('missions-preschool-levelup', data['missionspreschoollevelup']);
    await _preferences!.setInt('missions-preschool-namethepicture',
        data['missionspreschoolnamethepicture']);
    await _preferences!.setInt('missions-preschool-fillinthegaps',
        data['missionspreschoolfillinthegaps']);
    await _preferences!.setInt('missions-preschool-jigsawpuzzle',
        data['missionspreschooljigsawpuzzle']);
    await _preferences!.setInt('missions-preschool-spotthedifferences',
        data['missionspreschoolspotthedifferences']);
    await _preferences!.setInt(
        'missions-preschool-trickymaze', data['missionspreschooltrickymaze']);
    await _preferences!
        .setInt('missions-preteens-getgems', data['missionspreteensgetgems']);
    await _preferences!
        .setInt('missions-preteens-usegems', data['missionspreteensusegems']);
    await _preferences!.setInt('missions-preteens-gettripplestars',
        data['missionspreteensgettripplestars']);
    await _preferences!
        .setInt('missions-preteens-levelup', data['missionspreteenslevelup']);
    await _preferences!.setInt(
        'missions-preteens-biblequiz', data['missionspreteensbiblequiz']);
    await _preferences!.setInt('missions-preteens-fillinthegaps',
        data['missionspreteensfillinthegaps']);
    await _preferences!.setInt(
        'missions-preteens-namethebook', data['missionspreteensnamethebook']);
    await _preferences!.setInt(
        'missions-preteens-trueorfalse', data['missionspreteenstrueorfalse']);
    await _preferences!.setInt(
        'missions-preteens-whosaidthat', data['missionspreteenswhosaidthat']);
    await _preferences!.setInt(
        'missions-preteens-wordsearch', data['missionspreteenswordsearch']);
    await _preferences!
        .setInt('multiplier-preschool', data['multiplierpreschool']);
    await _preferences!
        .setInt('multiplier-preteens', data['multiplierpreteens']);

    await updateGameData('preschool', 'namethepicture', data);
    await updateGameData('preschool', 'fillinthegaps', data);
    await updateGameData('preschool', 'jigsawpuzzle', data);
    await updateGameData('preschool', 'spotthedifferences', data);
    await updateGameData('preschool', 'trickymaze', data);
    await updateGameData('preteens', 'biblequiz', data);
    await updateGameData('preteens', 'trueorfalse', data);
    await updateGameData('preteens', 'namethebook', data);
    await updateGameData('preteens', 'fillinthegaps', data);
    await updateGameData('preteens', 'whosaidthat', data);
    await updateGameData('preteens', 'wordsearch', data);
  }

  Future updateApplicationData(data) async {
    await _appData!.setItem('faqs', data['faqs']);
    await _appData!.setItem('videos', data['videos']);
    await _appData!.setItem('songs', data['songs']);
    await _appData!.setItem('stories', data['stories']);
    await _appData!.setItem('collections', data['collections']);
    await _appData!.setItem('gamepictures', data['gamepictures']);
    await _appData!.setItem('championsettings', data['champions']);
    await _appData!.setItem('celebrationsettings', data['celebrations']);
    await _appData!.setItem('didyouknow', data['didyouknow']);
    await _appData!.setItem('wordoftheday', data['wordoftheday']);
    await _appData!.setItem('dailyaffirmations', data['dailyaffirmations']);
    await _appData!
        .setItem('memoryverses-preschool', data['preschoolmemoryverse']);
    await _appData!
        .setItem('memoryverses-preteens', data['preteensmemoryverse']);
    await _appData!.setItem('nursery-coloringgame', data['coloringgame']);
    await _appData!.setItem('preschool-namethepicture', data['namethepicture']);
    await _appData!.setItem('preschool-fillinthegaps', data['fillthegaps']);
    await _appData!
        .setItem('preschool-spotthedifferences', data['spotthedifferences']);
    await _appData!.setItem('preschool-differences', data['differences']);
    await _appData!.setItem('preschool-trickymaze', data['trickymazepuzzles']);
    await _appData!.setItem('preteens-biblequiz', data['biblequiz']);
    await _appData!.setItem('preteens-fillinthegaps', data['fillinthegaps']);
    await _appData!.setItem('preteens-namethebook', data['namethebook']);
    await _appData!.setItem('preteens-trueorfalse', data['trueorfalse']);
    await _appData!.setItem('preteens-whosaidthat', data['whosaidthat']);
    await _appData!.setItem('preteens-wordsearch', data['wordsearchpuzzles']);
  }

  void updateChampions() async {
    _database.ref('champions').once().then((DatabaseEvent event) {
      Map championData = champions ?? {};

      if (event.snapshot.child('timestamp').value !=
          championData['timestamp']) {
        dayChampionShown = false;
        weekChampionShown = false;
        monthChampionShown = false;
        _appData!.setItem('champions', event.snapshot.value);
      }
    });
  }

  void updateSettings() {
    _database.ref('settings').once().then((DatabaseEvent event) async {
      Map data = event.snapshot.value as Map;

      await _preferences!.setString('uploadurl', data['uploadurl']);
      await _preferences!.setString('policyurl', data['policyurl']);
      await _preferences!.setString('dynamicurl', data['dynamicurl']);
      await _preferences!.setString('resourceurl', data['resourceurl']);
      await _preferences!.setString('androidversion', data['androidversion']);

      await _preferences!.setInt(
        'androidversionid',
        int.parse(data['androidversionid']),
      );

      await _preferences!.setInt(
        'androidupdatetime',
        int.parse(data['androidupdatetime']),
      );

      await _preferences!.setInt(
        'leaderboard-refresh-minutes-day',
        int.parse(data['leaderboardrefreshday']),
      );

      await _preferences!.setInt(
        'leaderboard-refresh-minutes-week',
        int.parse(data['leaderboardrefreshweek']),
      );

      await _preferences!.setInt(
        'leaderboard-refresh-minutes-month',
        int.parse(data['leaderboardrefreshmonth']),
      );

      await _preferences!.setInt(
        'leaderboard-refresh-minutes-year',
        int.parse(data['leaderboardrefreshyear']),
      );

      await _preferences!.setInt(
        'leaderboard-refresh-minutes-all',
        int.parse(data['leaderboardrefreshall']),
      );
    });
  }

  void syncUserDataAll() {
    syncUserData({
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'username': username,
      'country': country,
      'countrycode': countryCode,
      'state': state,
      'gems': gems,
      'hasprayed': hasPrayed,
      'avatar': avatar,
      'bonusnextreward': bonusNextReward,
      'championdaynextreward': championDayNextReward,
      'championweeknextreward': championWeekNextReward,
      'championmonthnextreward': championMonthNextReward,
      'lastonline': DateTime.now().toUtc().millisecondsSinceEpoch,
      'lastvisit': lastVisit,
      'lastvalidated': lastValidated,
      'missionspreschoolgetgems': getMissionData('preschool', 'getgems'),
      'missionspreschoolusegems': getMissionData('preschool', 'usegems'),
      'missionspreschoolgettripplestars':
          getMissionData('preschool', 'gettripplestars'),
      'missionspreschoollevelup': getMissionData('preschool', 'levelup'),
      'missionspreschoolnamethepicture':
          getMissionData('preschool', 'namethepicture'),
      'missionspreschoolfillinthegaps':
          getMissionData('preschool', 'fillinthegaps'),
      'missionspreschooljigsawpuzzle':
          getMissionData('preschool', 'jigsawpuzzle'),
      'missionspreschoolspotthedifferences':
          getMissionData('preschool', 'spotthedifferences'),
      'missionspreschooltrickymaze': getMissionData('preschool', 'trickymaze'),
      'missionspreteensgetgems': getMissionData('preteens', 'getgems'),
      'missionspreteensusegems': getMissionData('preteens', 'usegems'),
      'missionspreteensgettripplestars':
          getMissionData('preteens', 'gettripplestars'),
      'missionspreteenslevelup': getMissionData('preteens', 'levelup'),
      'missionspreteensbiblequiz': getMissionData('preteens', 'biblequiz'),
      'missionspreteensfillinthegaps':
          getMissionData('preteens', 'fillinthegaps'),
      'missionspreteensnamethebook': getMissionData('preteens', 'namethebook'),
      'missionspreteenstrueorfalse': getMissionData('preteens', 'trueorfalse'),
      'missionspreteenswhosaidthat': getMissionData('preteens', 'whosaidthat'),
      'missionspreteenswordsearch': getMissionData('preteens', 'wordsearch'),
      'multiplierpreschool': getMultiplier('preschool'),
      'multiplierpreteens': getMultiplier('preteens'),
      'preschoolnamethepicturebest': getBest('preschool-namethepicture'),
      'preschoolnamethepicturescore': getScore('preschool-namethepicture'),
      'preschoolnamethepicturelevel': getLevel('preschool-namethepicture'),
      'preschoolfillinthegapsbest': getBest('preschool-fillinthegaps'),
      'preschoolfillinthegapsscore': getScore('preschool-fillinthegaps'),
      'preschoolfillinthegapslevel': getLevel('preschool-fillinthegaps'),
      'preschooljigsawpuzzlebest': getBest('preschool-jigsawpuzzle'),
      'preschooljigsawpuzzlescore': getScore('preschool-jigsawpuzzle'),
      'preschooljigsawpuzzlelevel': getLevel('preschool-jigsawpuzzle'),
      'preschoolspotthedifferencesbest':
          getBest('preschool-spotthedifferences'),
      'preschoolspotthedifferencesscore':
          getScore('preschool-spotthedifferences'),
      'preschoolspotthedifferenceslevel':
          getLevel('preschool-spotthedifferences'),
      'preschooltrickymazebest': getBest('preschool-trickymaze'),
      'preschooltrickymazescore': getScore('preschool-trickymaze'),
      'preschooltrickymazelevel': getLevel('preschool-trickymaze'),
      'preteensbiblequizbest': getBest('preteens-biblequiz'),
      'preteensbiblequizscore': getScore('preteens-biblequiz'),
      'preteensbiblequizlevel': getLevel('preteens-biblequiz'),
      'preteenstrueorfalsebest': getBest('preteens-trueorfalse'),
      'preteenstrueorfalsescore': getScore('preteens-trueorfalse'),
      'preteenstrueorfalselevel': getLevel('preteens-trueorfalse'),
      'preteensnamethebookbest': getBest('preteens-namethebook'),
      'preteensnamethebookscore': getScore('preteens-namethebook'),
      'preteensnamethebooklevel': getLevel('preteens-namethebook'),
      'preteensfillinthegapsbest': getBest('preteens-fillinthegaps'),
      'preteensfillinthegapsscore': getScore('preteens-fillinthegaps'),
      'preteensfillinthegapslevel': getLevel('preteens-fillinthegaps'),
      'preteenswhosaidthatbest': getBest('preteens-whosaidthat'),
      'preteenswhosaidthatscore': getScore('preteens-whosaidthat'),
      'preteenswhosaidthatlevel': getLevel('preteens-whosaidthat'),
      'preteenswordsearchbest': getBest('preteens-wordsearch'),
      'preteenswordsearchscore': getScore('preteens-wordsearch'),
      'preteenswordsearchlevel': getLevel('preteens-wordsearch'),
    });
  }

  Future fullLogin() async {
    String idToken = await AuthService().currentUser!.getIdToken();

    await Dio()
        .get(
      '$apiUrl/user',
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      ),
    )
        .then((Response response) async {
      if (response.data['status'] == 'success') {
        await updateUserData(response.data['data']);
        fullyLoggedIn = true;
      }
    });
  }

  Future clearData() async {
    await _appData?.clear();
    await _preferences?.clear();
  }
}
