import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class DailyAffirmations extends StatefulWidget {
  const DailyAffirmations({Key? key}) : super(key: key);

  @override
  _DailyAffirmationsState createState() => _DailyAffirmationsState();
}

class _DailyAffirmationsState extends State<DailyAffirmations> {
  int? current;
  Timer? timer;
  List affirmations = [];
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    for (Map value in DatabaseService().dailyAffirmations!) {
      DateTime date = DateTime.parse(value['date']).toUtc();
      DateTime dateFuture = date.add(const Duration(days: 30));
      DateTime now = DateTime.now().toUtc();

      if (now.isAfter(dateFuture)) affirmations.add(value);
    }

    current = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(0))
            .inDays %
        affirmations.length;

    AudioService().pauseMusic();

    timer = Timer(const Duration(seconds: 6, milliseconds: 500), () {
      audioPlayer.open(
        Playlist(
          audios: List.generate(
            5,
            (_) => Audio.file(
              "${DatabaseService().downloadPath}/dailyaffirmations/${affirmations[current!]['audio']}",
            ),
          ),
        ),
        volume: AudioService().voiceVolume,
        showNotification: false,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.00,
          height: 274.81,
          padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/bg-dailywordaffirmation.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                affirmations[current!]['text'],
                style: TextStyle(
                  fontSize: 22.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'SAY THIS 5 TIMES TO YOURSELF',
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    AudioService().normalizeMusic();
    super.dispose();
  }
}
