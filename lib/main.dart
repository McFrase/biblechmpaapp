import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:biblechamps/games/nursery/abcgame.dart';
import 'package:biblechamps/games/nursery/coloringgame.dart';
import 'package:biblechamps/games/nursery/learnabc.dart';
import 'package:biblechamps/games/nursery/scratchtoreveal.dart';
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
import 'package:biblechamps/pages/auth.dart';
import 'package:biblechamps/pages/data.dart';
import 'package:biblechamps/pages/download.dart';
import 'package:biblechamps/pages/games.dart';
import 'package:biblechamps/pages/home.dart';
import 'package:biblechamps/pages/splash.dart';
import 'package:biblechamps/pages/videos.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  await Firebase.initializeApp();

  AuthService().authInit();

  await DatabaseService().databaseInit();

  AudioService().audioInit();

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'default',
        channelName: 'Default',
        channelDescription: 'Default Channel',
        channelShowBadge: true,
        defaultColor: Colors.blue,
        importance: NotificationImportance.Max,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ],
  );

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen(showLocalNotification);
  FirebaseMessaging.onBackgroundMessage(showLocalNotification);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const MyApp());
}

// Declared as global, outside of any class
Future showLocalNotification(RemoteMessage message) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'default',
      largeIcon: 'resource://drawable/icon',
      title: message.notification?.title,
      body: message.notification?.body,
      displayOnForeground: true,
      displayOnBackground: true,
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  void initUri() async {
    Uri? uri = await getInitialUri();
    if (uri?.path == '/resources') DatabaseService.launchUrl = true;
  }

  @override
  void initState() {
    super.initState();
    initUri();
    KeepScreenOn.turnOn();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          if (Platform.isAndroid) {
            if (isKeyboardVisible) {
              FlutterWindowManager.clearFlags(
                  FlutterWindowManager.FLAG_FULLSCREEN);
            } else {
              FlutterWindowManager.addFlags(
                  FlutterWindowManager.FLAG_FULLSCREEN);
            }
          }

          return MaterialApp(
            title: 'Bible Champs',
            theme: ThemeData(
              fontFamily: 'Bubblegum Sans',
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
                accentColor: Colors.orange,
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: '/splashpage',
            routes: {
              '/auth': (context) => const AuthPage(),
              '/data': (context) => const DataPage(),
              '/home': (context) => const HomePage(),
              '/splashpage': (context) => const SplashPage(),
              '/downloadfiles': (context) => const DownloadFilesPage(),
              '/watchvideos': (context) => const VideosPage('videos'),
              '/singsongs': (context) => const VideosPage('songs'),
              '/biblestories': (context) => const VideosPage('stories'),
              '/playgames': (context) => GamesPage('all'),
              '/listnurserygames': (context) => GamesPage('nursery'),
              '/listpreschoolgames': (context) => GamesPage('preschool'),
              '/listpreteensgames': (context) => GamesPage('preteens'),
              '/playnurserylearnabc': (context) => const NurseryLearnAbcGame(),
              '/playnurseryabcgame': (context) => const NurseryAbcGameGame(),
              '/playnurserycoloringgame': (context) =>
                  const NurseryColoringGameGame(),
              '/playnurseryscratchtoreveal': (context) =>
                  const NurseryScratchToRevealGame(),
              '/playpreschoolnamethepicture': (context) =>
                  const PreschoolNameThePictureGame(),
              '/playpreschoolfillinthegaps': (context) =>
                  const PreschoolFillInTheGapsGame(),
              '/playpreschooljigsawpuzzle': (context) =>
                  const PreschoolJigsawPuzzleGame(),
              '/playpreschoolspotthedifferences': (context) =>
                  const PreschoolSpotTheDifferencesGame(),
              '/playpreschooltrickymaze': (context) =>
                  const PreschoolTrickyMazeGame(),
              '/playpreteensbiblequiz': (context) =>
                  const PreteensBibleQuizGame(),
              '/playpreteensfillinthegaps': (context) =>
                  const PreteensFillInTheGapsGame(),
              '/playpreteensnamethebook': (context) =>
                  const PreteensNameTheBookGame(),
              '/playpreteenstrueorfalse': (context) =>
                  const PreteensTrueOrFalseGame(),
              '/playpreteenswhosaidthat': (context) =>
                  const PreteensWhoSaidThatGame(),
              '/playpreteenswordsearch': (context) =>
                  const PreteensWordSearchGame(),
              '/playpreschoolrandomgames': (context) =>
                  GameService().getRandomGame('preschool'),
              '/playpreteensrandomgames': (context) =>
                  GameService().getRandomGame('preteens'),
            },
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        AudioService().pauseMusic();
        break;
      case AppLifecycleState.resumed:
        AudioService().playMusic();
        break;
      case AppLifecycleState.inactive:
        AudioService().pauseMusic();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
