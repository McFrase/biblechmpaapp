import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class WordOfTheDay extends StatefulWidget {
  const WordOfTheDay({Key? key}) : super(key: key);

  @override
  _WordOfTheDayState createState() => _WordOfTheDayState();
}

class _WordOfTheDayState extends State<WordOfTheDay> {
  int? current;
  Timer? timer;
  List words = [];
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    for (Map value in DatabaseService().wordOfTheDay!) {
      DateTime date = DateTime.parse(value['date']).toUtc();
      DateTime dateFuture = date.add(const Duration(days: 30));
      DateTime now = DateTime.now().toUtc();

      if (now.isAfter(dateFuture)) words.add(value);
    }

    current = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(0))
            .inDays %
        words.length;

    AudioService().pauseMusic();

    timer = Timer(const Duration(seconds: 2, milliseconds: 250), () {
      audioPlayer.open(
        Audio.file(
            "${DatabaseService().downloadPath}/wordoftheday/${words[current!]['audio']}"),
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
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/bg-wordoftheday.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    words[current!]['word'],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: words[current!]['interpretation'] == ''
                        ? const SizedBox()
                        : Text(
                            '(${words[current!]['interpretation']})',
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[700],
                            ),
                          ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Origin: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: words[current!]['origin'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Usage: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: words[current!]['usage'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Meaning: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: words[current!]['meaning'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Occurs: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: words[current!]['occurence'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Found in: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: words[current!]['reference'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(),
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
