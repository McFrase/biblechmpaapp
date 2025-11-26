import 'dart:convert';
import 'dart:io';

import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DownloadFilesPage extends StatefulWidget {
  const DownloadFilesPage({Key? key}) : super(key: key);

  @override
  _DownloadFilesPageState createState() => _DownloadFilesPageState();
}

class _DownloadFilesPageState extends State<DownloadFilesPage> {
  int totalSize = 1;
  int downloadedSize = 0;
  bool isError = true;
  bool permissionGranted = false;

  void downloadAsset() async {
    permissionGranted = true;

    try {
      await Dio().download(
        'https://reg.loveworldchildrensministry.org/api/data',
        '${DatabaseService().downloadPath}/data.zip',
        onReceiveProgress: (int count, int total) {
          setState(() {
            isError = false;
            totalSize = total;
            downloadedSize = count;
          });
        },
      );

      await ZipFile.extractToDirectory(
        zipFile: File('${DatabaseService().downloadPath}/data.zip'),
        destinationDir: Directory(DatabaseService().downloadPath),
      );

      await File('${DatabaseService().downloadPath}/data.zip').delete();

      await File('${DatabaseService().downloadPath}/version.json')
          .writeAsString(json.encode(DatabaseService().androidVersion));

      await File('${DatabaseService().downloadPath}/lastvalidated.json')
          .writeAsString(
              json.encode(DateTime.now().toUtc().millisecondsSinceEpoch));

      UiService().nextPage(context);
    } catch (exception) {
      setState(() => isError = true);
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
        child: Center(
          child: SizedBox(
            width: 300,
            height: 160,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/icon.png',
                      width: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      permissionGranted
                          ? 'Internet Connection Required, Please Wait!'
                          : 'Download Application Data for Bible Champs',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    isError
                        ? ElevatedButton.icon(
                            label:
                                Text(permissionGranted ? 'RETRY' : 'PROCEED'),
                            icon: FaIcon(
                              permissionGranted
                                  ? FontAwesomeIcons.redo
                                  : FontAwesomeIcons.download,
                              size: 16,
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: permissionGranted
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            onPressed: () => downloadAsset(),
                          )
                        : LinearPercentIndicator(
                            lineHeight: 12,
                            percent: downloadedSize / totalSize,
                            progressColor: Colors.orange,
                            center: Text(
                              totalSize == 1
                                  ? 'processing...'
                                  : downloadedSize == totalSize
                                      ? 'finalizing...'
                                      : '${(downloadedSize / (1024 * 1000)).toStringAsFixed(2)} of ${(totalSize / (1024 * 1000)).toStringAsFixed(2)}MB',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
