import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:biblechamps/services/database.dart';

class AudioService {
  static Timer? _timer;
  static final AssetsAudioPlayer _music = AssetsAudioPlayer();
  static final AssetsAudioPlayer _sfx = AssetsAudioPlayer();
  static final AssetsAudioPlayer _voice = AssetsAudioPlayer();
  static double _appVolume = DatabaseService().getVolume('app') ?? 1.0;
  static double _sfxVolume = DatabaseService().getVolume('sfx') ?? 1.0;
  static double _musicVolume = DatabaseService().getVolume('music') ?? 1.0;
  static double _voiceVolume = DatabaseService().getVolume('voice') ?? 1.0;

  double get appVolume {
    return _appVolume;
  }

  double get sfxVolume {
    return _sfxVolume;
  }

  double get musicVolume {
    return _musicVolume;
  }

  double get voiceVolume {
    return _voiceVolume;
  }

  set appVolume(double value) {
    _appVolume = value;
    _music.setVolume(_musicVolume * value);
    _sfx.setVolume(_sfxVolume * value);
    _voice.setVolume(_voiceVolume * value);
    DatabaseService().setVolume('app', value);
  }

  set sfxVolume(double value) {
    _sfxVolume = value;
    _sfx.setVolume(value * _appVolume);
    DatabaseService().setVolume('sfx', value);
  }

  set musicVolume(double value) {
    _musicVolume = value;
    _music.setVolume(value * _appVolume);
    DatabaseService().setVolume('music', value);
  }

  set voiceVolume(double value) {
    _voiceVolume = value;
    _voice.setVolume(value * _appVolume);
    DatabaseService().setVolume('voice', value);
  }

  void playMusic() {
    _music.play();
  }

  void pauseMusic() {
    _music.pause();
  }

  void reduceMusic() {
    _music.setVolume(0.05 * _musicVolume * _appVolume);
  }

  void normalizeMusic() {
    _timer?.cancel();
    _sfx.stop();
    _voice.stop();
    _music.setVolume(_musicVolume * _appVolume);
    _music.play();
  }

  void audioInit() {
    _music.open(
      Audio('assets/audios/soundtrack.mp3'),
      autoStart: true,
      volume: _musicVolume * _appVolume,
      showNotification: false,
      loopMode: LoopMode.single,
      // playInBackground: PlayInBackground.disabledRestoreOnForeground, // has bugs, doesn't work first time
    );
  }

  void playVoiceOnce(audio, duration) async {
    reduceMusic();
    _voice.open(
      Audio.file(audio),
      autoStart: true,
      volume: _voiceVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _voice.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void playSfxOnce(audio, duration) async {
    reduceMusic();
    _sfx.open(
      Audio.file(audio),
      autoStart: true,
      volume: _sfxVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _sfx.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void playShockWave() async {
    AssetsAudioPlayer temp = AssetsAudioPlayer();
    temp.open(
      Audio.file('${DatabaseService().downloadPath}/audios/shockwave.mp3'),
      autoStart: true,
      volume: _sfxVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    await Future.delayed(const Duration(seconds: 2));
    temp.dispose();
  }

  void playPop() {
    reduceMusic();
    AssetsAudioPlayer.playAndForget(
      Audio.file('${DatabaseService().downloadPath}/audios/pop.mp3'),
      volume: _sfxVolume * _appVolume,
    );
  }

  void playBuzz() {
    reduceMusic();
    AssetsAudioPlayer.playAndForget(
      Audio.file('${DatabaseService().downloadPath}/audios/buzz.mp3'),
      volume: _sfxVolume * _appVolume,
    );
  }

  void playChime() async {
    AssetsAudioPlayer temp = AssetsAudioPlayer();
    temp.open(
      Audio.file('${DatabaseService().downloadPath}/audios/treasure.mp3'),
      autoStart: true,
      volume: _sfxVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    await Future.delayed(const Duration(seconds: 3));
    temp.dispose();
  }

  void playCheer() async {
    AssetsAudioPlayer temp = AssetsAudioPlayer();
    temp.open(
      Audio.file('${DatabaseService().downloadPath}/audios/kidscheering.mp3'),
      autoStart: true,
      volume: _sfxVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    await Future.delayed(const Duration(seconds: 5, milliseconds: 500));
    temp.dispose();
  }

  void sayVoice(Duration seek, Duration duration) async {
    reduceMusic();
    _voice.open(
      Audio.file('${DatabaseService().downloadPath}/audios/app.mp3'),
      autoStart: true,
      seek: seek,
      volume: _voiceVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _voice.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void saySecondary(Duration seek, Duration duration) async {
    reduceMusic();
    _voice.open(
      Audio.file('${DatabaseService().downloadPath}/audios/secondary.mp3'),
      autoStart: true,
      seek: seek,
      volume: _voiceVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _voice.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void clockTick() {
    _sfx.open(
      Audio.file('${DatabaseService().downloadPath}/audios/clock-tick.mp3'),
      autoStart: true,
      volume: _sfxVolume * _appVolume,
      showNotification: false,
      loopMode: LoopMode.single,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );
  }

  void sayAlphabets(letter) {
    Duration seek;
    Duration duration;

    switch (letter) {
      case 'a':
        {
          seek = const Duration(seconds: 4, milliseconds: 250);
          duration = const Duration(milliseconds: 1200);
        }
        break;

      case 'b':
        {
          seek = const Duration(seconds: 9, milliseconds: 700);
          duration = const Duration(milliseconds: 1400);
        }
        break;

      case 'c':
        {
          seek = const Duration(seconds: 16, milliseconds: 350);
          duration = const Duration(milliseconds: 1250);
        }
        break;

      case 'd':
        {
          seek = const Duration(seconds: 22, milliseconds: 750);
          duration = const Duration(milliseconds: 1250);
        }
        break;

      case 'e':
        {
          seek = const Duration(seconds: 30, milliseconds: 250);
          duration = const Duration(milliseconds: 1250);
        }
        break;

      case 'f':
        {
          seek = const Duration(seconds: 36, milliseconds: 0);
          duration = const Duration(milliseconds: 1250);
        }
        break;

      case 'g':
        {
          seek = const Duration(seconds: 42, milliseconds: 650);
          duration = const Duration(milliseconds: 1250);
        }
        break;

      case 'h':
        {
          seek = const Duration(seconds: 52, milliseconds: 200);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'i':
        {
          seek = const Duration(seconds: 58, milliseconds: 600);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'j':
        {
          seek = const Duration(minutes: 1, seconds: 5, milliseconds: 300);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'k':
        {
          seek = const Duration(minutes: 1, seconds: 11, milliseconds: 300);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'l':
        {
          seek = const Duration(minutes: 1, seconds: 16, milliseconds: 750);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'm':
        {
          seek = const Duration(minutes: 1, seconds: 22, milliseconds: 950);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'n':
        {
          seek = const Duration(minutes: 1, seconds: 30, milliseconds: 600);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'o':
        {
          seek = const Duration(minutes: 1, seconds: 36, milliseconds: 0);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'p':
        {
          seek = const Duration(minutes: 1, seconds: 44, milliseconds: 300);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'q':
        {
          seek = const Duration(minutes: 1, seconds: 50, milliseconds: 250);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'r':
        {
          seek = const Duration(minutes: 1, seconds: 57, milliseconds: 50);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 's':
        {
          seek = const Duration(minutes: 2, seconds: 3, milliseconds: 900);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 't':
        {
          seek = const Duration(minutes: 2, seconds: 11, milliseconds: 950);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'u':
        {
          seek = const Duration(minutes: 2, seconds: 21, milliseconds: 300);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'v':
        {
          seek = const Duration(minutes: 2, seconds: 26, milliseconds: 550);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'w':
        {
          seek = const Duration(minutes: 2, seconds: 33, milliseconds: 250);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'x':
        {
          seek = const Duration(minutes: 2, seconds: 42, milliseconds: 350);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'y':
        {
          seek = const Duration(minutes: 2, seconds: 53, milliseconds: 750);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      case 'z':
        {
          seek = const Duration(minutes: 3, seconds: 0, milliseconds: 900);
          duration = const Duration(milliseconds: 1500);
        }
        break;

      default:
        {
          seek = Duration.zero;
          duration = const Duration(milliseconds: 100);
        }
    }

    reduceMusic();
    _voice.open(
      Audio.file('${DatabaseService().downloadPath}/audios/alphabets.mp3'),
      autoStart: true,
      seek: seek,
      volume: _voiceVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _voice.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void sayAlphabetInfo(letter) {
    Duration seek;
    Duration duration;

    switch (letter) {
      case 'a':
        {
          seek = const Duration(seconds: 4, milliseconds: 250);
          duration = const Duration(seconds: 9, milliseconds: 700) - seek;
        }
        break;

      case 'b':
        {
          seek = const Duration(seconds: 9, milliseconds: 700);
          duration = const Duration(seconds: 16, milliseconds: 350) - seek;
        }
        break;

      case 'c':
        {
          seek = const Duration(seconds: 16, milliseconds: 350);
          duration = const Duration(seconds: 22, milliseconds: 750) - seek;
        }
        break;

      case 'd':
        {
          seek = const Duration(seconds: 22, milliseconds: 750);
          duration = const Duration(seconds: 30, milliseconds: 250) - seek;
        }
        break;

      case 'e':
        {
          seek = const Duration(seconds: 30, milliseconds: 250);
          duration = const Duration(seconds: 36, milliseconds: 0) - seek;
        }
        break;

      case 'f':
        {
          seek = const Duration(seconds: 36, milliseconds: 0);
          duration = const Duration(seconds: 42, milliseconds: 650) - seek;
        }
        break;

      case 'g':
        {
          seek = const Duration(seconds: 42, milliseconds: 650);
          duration = const Duration(seconds: 52, milliseconds: 200) - seek;
        }
        break;

      case 'h':
        {
          seek = const Duration(seconds: 52, milliseconds: 200);
          duration = const Duration(seconds: 58, milliseconds: 600) - seek;
        }
        break;

      case 'i':
        {
          seek = const Duration(seconds: 58, milliseconds: 600);
          duration =
              const Duration(minutes: 1, seconds: 5, milliseconds: 300) - seek;
        }
        break;

      case 'j':
        {
          seek = const Duration(minutes: 1, seconds: 5, milliseconds: 300);
          duration =
              const Duration(minutes: 1, seconds: 11, milliseconds: 300) - seek;
        }
        break;

      case 'k':
        {
          seek = const Duration(minutes: 1, seconds: 11, milliseconds: 300);
          duration =
              const Duration(minutes: 1, seconds: 16, milliseconds: 750) - seek;
        }
        break;

      case 'l':
        {
          seek = const Duration(minutes: 1, seconds: 16, milliseconds: 750);
          duration =
              const Duration(minutes: 1, seconds: 22, milliseconds: 950) - seek;
        }
        break;

      case 'm':
        {
          seek = const Duration(minutes: 1, seconds: 22, milliseconds: 950);
          duration =
              const Duration(minutes: 1, seconds: 30, milliseconds: 600) - seek;
        }
        break;

      case 'n':
        {
          seek = const Duration(minutes: 1, seconds: 30, milliseconds: 600);
          duration =
              const Duration(minutes: 1, seconds: 36, milliseconds: 0) - seek;
        }
        break;

      case 'o':
        {
          seek = const Duration(minutes: 1, seconds: 36, milliseconds: 0);
          duration =
              const Duration(minutes: 1, seconds: 44, milliseconds: 300) - seek;
        }
        break;

      case 'p':
        {
          seek = const Duration(minutes: 1, seconds: 44, milliseconds: 300);
          duration =
              const Duration(minutes: 1, seconds: 50, milliseconds: 250) - seek;
        }
        break;

      case 'q':
        {
          seek = const Duration(minutes: 1, seconds: 50, milliseconds: 250);
          duration =
              const Duration(minutes: 1, seconds: 57, milliseconds: 50) - seek;
        }
        break;

      case 'r':
        {
          seek = const Duration(minutes: 1, seconds: 57, milliseconds: 50);
          duration =
              const Duration(minutes: 2, seconds: 3, milliseconds: 900) - seek;
        }
        break;

      case 's':
        {
          seek = const Duration(minutes: 2, seconds: 3, milliseconds: 900);
          duration =
              const Duration(minutes: 2, seconds: 11, milliseconds: 950) - seek;
        }
        break;

      case 't':
        {
          seek = const Duration(minutes: 2, seconds: 11, milliseconds: 950);
          duration =
              const Duration(minutes: 2, seconds: 21, milliseconds: 300) - seek;
        }
        break;

      case 'u':
        {
          seek = const Duration(minutes: 2, seconds: 21, milliseconds: 300);
          duration =
              const Duration(minutes: 2, seconds: 26, milliseconds: 550) - seek;
        }
        break;

      case 'v':
        {
          seek = const Duration(minutes: 2, seconds: 26, milliseconds: 550);
          duration =
              const Duration(minutes: 2, seconds: 33, milliseconds: 250) - seek;
        }
        break;

      case 'w':
        {
          seek = const Duration(minutes: 2, seconds: 33, milliseconds: 250);
          duration =
              const Duration(minutes: 2, seconds: 42, milliseconds: 350) - seek;
        }
        break;

      case 'x':
        {
          seek = const Duration(minutes: 2, seconds: 42, milliseconds: 350);
          duration =
              const Duration(minutes: 2, seconds: 53, milliseconds: 750) - seek;
        }
        break;

      case 'y':
        {
          seek = const Duration(minutes: 2, seconds: 53, milliseconds: 750);
          duration =
              const Duration(minutes: 3, seconds: 0, milliseconds: 900) - seek;
        }
        break;

      case 'z':
        {
          seek = const Duration(minutes: 3, seconds: 0, milliseconds: 900);
          duration =
              const Duration(minutes: 3, seconds: 7, milliseconds: 500) - seek;
        }
        break;

      default:
        {
          seek = Duration.zero;
          duration = const Duration(milliseconds: 100);
        }
    }

    reduceMusic();
    _voice.open(
      Audio.file('${DatabaseService().downloadPath}/audios/alphabets.mp3'),
      autoStart: true,
      seek: seek,
      volume: _voiceVolume * _appVolume,
      showNotification: false,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
    );

    _timer?.cancel();
    _timer = Timer(duration, () {
      _voice.stop();
      _music.setVolume(_musicVolume * _appVolume);
    });
  }

  void destroyAudio() {
    _timer?.cancel();
    _music.stop();
    _voice.stop();
    _sfx.stop();
  }
}
