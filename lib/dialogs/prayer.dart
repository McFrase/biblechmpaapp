import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class Prayer extends StatefulWidget {
  const Prayer({Key? key}) : super(key: key);

  @override
  _PrayerState createState() => _PrayerState();
}

class _PrayerState extends State<Prayer> {
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    AudioService().pauseMusic();

    audioPlayer.open(
      Audio('${DatabaseService().downloadPath}/audios/prayer.mp3'),
      volume: AudioService().voiceVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );
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
          height: 265,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/bg-prayer.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '“Oh Lord God, I come to you in the Name of your Son, Jesus Christ. I believe in my heart that He came into this world and died for my sins and the sins of the whole world. I believe that He was raised up from the dead and He is alive today. I confess with my mouth, that Jesus Christ is Lord of my life. I receive eternal life into my spirit. Therefore I declare that I am saved. I am born again. I now have Christ dwelling in me. Thank you Father.”',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                JelloIn(
                  child: ElevatedButton(
                    child: const Text('CLICK HERE TO CONFIRM'),
                    onPressed: () {
                      DatabaseService().hasPrayed = 1;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    AudioService().normalizeMusic();
    super.dispose();
  }
}
