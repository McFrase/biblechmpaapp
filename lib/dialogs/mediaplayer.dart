import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPlayer extends StatefulWidget {
  final String location;

  const MediaPlayer(this.location, {Key? key}) : super(key: key);

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  bool mediaControlIsHidden = true;
  VideoPlayerController? _controller;
  AnimationController? mediaControlAnimationController;

  @override
  void initState() {
    super.initState();
    AudioService().pauseMusic();
    _controller = VideoPlayerController.file(File(widget.location));
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.play();

    Future(() => mediaControlAnimationController!.forward());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      mediaControlIsHidden
                          ? mediaControlAnimationController!.reverse()
                          : mediaControlAnimationController!.forward();
                      mediaControlIsHidden = !mediaControlIsHidden;
                    },
                    child: VideoPlayer(_controller!),
                  ),
                  ClosedCaption(text: _controller!.value.caption.text),
                  VideoProgressIndicator(_controller!, allowScrubbing: true),
                ],
              ),
            ),
          ),
          FadeIn(
            animate: false,
            controller: (controller) =>
                mediaControlAnimationController = controller,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: Container(
                        width: 48.91,
                        height: 50,
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(
                                '${DatabaseService().downloadPath}/images/button-backward.png')),
                          ),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0.0),
                          ),
                          onPressed: () {
                            _controller!.seekTo(Duration(
                                seconds: _controller!.value.position.inSeconds -
                                    10));
                          },
                          child: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: Container(
                        width: 48.91,
                        height: 50,
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(
                                "${DatabaseService().downloadPath}/images/button-${_controller!.value.isPlaying ? "pause" : "play"}.png")),
                          ),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0.0),
                          ),
                          onPressed: () {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                            setState(() {});
                          },
                          child: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: Container(
                        width: 48.91,
                        height: 50,
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(
                                '${DatabaseService().downloadPath}/images/button-forward.png')),
                          ),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0.0),
                          ),
                          onPressed: () {
                            _controller!.seekTo(Duration(
                                seconds: _controller!.value.position.inSeconds +
                                    10));
                          },
                          child: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: Container(
                        width: 48.91,
                        height: 50,
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(
                                '${DatabaseService().downloadPath}/images/button-stop.png')),
                          ),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    mediaControlAnimationController?.dispose();
    AudioService().playMusic();
    super.dispose();
  }
}
