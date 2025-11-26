import 'dart:io';

import 'package:biblechamps/dialogs/mediaplayer.dart';
import 'package:biblechamps/dialogs/prayer.dart';
import 'package:biblechamps/services/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class VideosPage extends StatefulWidget {
  final String type;
  final int? collectionId;

  const VideosPage(this.type, {Key? key, this.collectionId}) : super(key: key);

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List videos = [];
  List display = [];
  List progress = [];
  List collections = DatabaseService().collections!;
  String? typePath;

  void showPrayer() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const Prayer(),
    );
  }

  Future playVideo(String filePath) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => MediaPlayer(filePath),
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (widget.type == 'stories' && DatabaseService().hasPrayed == 0) {
      showPrayer();
    }
  }

  Widget buildActionForTask(int index, String video) {
    if (File('$typePath/$video').existsSync()) {
      return const Padding(
        padding: EdgeInsets.all(5),
        child: FaIcon(
          FontAwesomeIcons.play,
          color: Colors.green,
          size: 16.0,
        ),
      );
    } else if (progress[index] > 0.0) {
      return CircularPercentIndicator(
        radius: 13.5,
        lineWidth: 2,
        percent: progress[index] > 100 ? 1.0 : progress[index] / 100,
        progressColor: Colors.orange,
        center: Text(
          '${progress[index] > 100 ? 100 : progress[index].round()}%',
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(5),
        child: FaIcon(
          FontAwesomeIcons.download,
          color: Colors.orange,
          size: 16.0,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    typePath = '${DatabaseService().downloadPath}/${widget.type}';

    Directory(typePath!).create();

    if (widget.type == 'songs') videos = DatabaseService().songs!;
    if (widget.type == 'videos') videos = DatabaseService().videos!;
    if (widget.type == 'stories') videos = DatabaseService().stories!;

    for (Map video in videos) {
      if (widget.collectionId != null) {
        if (video['collectionsid'] == widget.collectionId) {
          display.add({'videoid': video['id']});
          progress.add(0.0);
        }
      } else {
        if (video['collectionsid'] != null) {
          if (display.indexWhere(
                  (item) => item['collectionsid'] == video['collectionsid']) ==
              -1) {
            display.add({'collectionsid': video['collectionsid']});
          }
        } else {
          display.add({'videoid': video['id']});
          progress.add(0.0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/homebg.png'),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.50),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7.5, 7.5, 0.0, 7.5),
                      child: ClipOval(
                        child: Container(
                          width: 48.91,
                          height: 50,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-back.png')),
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
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Image.file(
                    File(
                        "${DatabaseService().downloadPath}/images/text-${widget.type == 'videos' ? 'watchvideos' : (widget.type == 'songs' ? 'singsongs' : 'biblestories')}.png"),
                    height: 75,
                  ),
                ),
                widget.type == 'stories'
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 7.5, 7.5, 7.5),
                        child: ClipOval(
                          child: Container(
                            width: 48.91,
                            height: 50,
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(
                                    '${DatabaseService().downloadPath}/images/button-voice.png')),
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () => showPrayer(),
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: 50),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        display.asMap().entries.map<Widget>((MapEntry entry) {
                      Map detail = (entry.value['videoid'] != null
                              ? videos
                              : collections)
                          .firstWhere((item) =>
                              item['id'] ==
                              (entry.value['videoid'] ??
                                  entry.value['collectionsid']));

                      return GestureDetector(
                        onTap: () async {
                          if (entry.value['collectionsid'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => VideosPage(
                                  widget.type,
                                  collectionId: entry.value['collectionsid'],
                                ),
                              ),
                            );
                          } else {
                            if (File('$typePath/${detail["video"]}')
                                .existsSync()) {
                              playVideo('$typePath/${detail["video"]}');
                            } else {
                              try {
                                await Dio().download(
                                  '${DatabaseService().uploadUrl}/${widget.type}/${detail["video"]}',
                                  '${DatabaseService().temporaryPath}/${widget.type}/${detail["video"]}',
                                  onReceiveProgress: (int count, int total) {
                                    setState(() {
                                      progress[entry.key] =
                                          (count / total) * 100;
                                    });
                                  },
                                );

                                await File(
                                        '${DatabaseService().temporaryPath}/${widget.type}/${detail["video"]}')
                                    .rename('$typePath/${detail["video"]}');
                              } catch (exception) {
                                progress[entry.key] = 0.0;
                              }
                            }
                          }
                        },
                        child: SizedBox(
                          width: 225,
                          height: 175,
                          child: Card(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: 175,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(
                                            "${DatabaseService().downloadPath}/thumbnails/${detail['thumbnail']}"),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.black.withOpacity(0.75),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        detail['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      entry.value['collectionsid'] != null
                                          ? const FaIcon(
                                              IconDataSolid(0xf07b),
                                              color: Colors.orange,
                                              size: 20.0,
                                            )
                                          : buildActionForTask(
                                              entry.key, detail['video']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
