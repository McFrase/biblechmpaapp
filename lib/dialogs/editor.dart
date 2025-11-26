import 'dart:io';
import 'dart:typed_data';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:biblechamps/services/database.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Editor extends StatefulWidget {
  final String type;
  final Uint8List bytes;

  const Editor(this.type, this.bytes, {Key? key}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Map? dimensions;
  Image? imageFile;
  bool isEditing = true;
  int toastMode = 1; // controls repeating toasts
  ScreenshotController screenshotController = ScreenshotController();

  bool interceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return true;
    if (!isEditing) {
      setState(() => isEditing = true);
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptor);

    dimensions = DatabaseService().celebrationBounds[widget.type];

    String fileName = DatabaseService()
        .celebrationSettings!
        .firstWhere((value) => value['name'] == widget.type)['image'];

    imageFile = Image.file(
      File('${DatabaseService().downloadPath}/celebrations/$fileName'),
      height: dimensions!['height'],
    );

    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      if (toastMode == 1) {
        toastMode = 2;

        Fluttertoast.showToast(
          msg: 'Pinch, zoom and drag face into the circle',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 5500)).then((_) {
      if (isEditing && toastMode == 2) {
        toastMode = 3;

        Fluttertoast.showToast(
          msg: 'Tap image when ready',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Screenshot(
        controller: screenshotController,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: dimensions!['width'],
              height: dimensions!['height'],
              color: isEditing ? Colors.transparent : Colors.black,
            ),
            Positioned(
              left: dimensions!['editor-distance-left'],
              top: dimensions!['editor-distance-top'],
              child: GestureDetector(
                onTap: () {
                  toastMode = 4;

                  Fluttertoast.showToast(
                    msg: 'Tap to share',
                    toastLength: Toast.LENGTH_LONG,
                  );

                  Future.delayed(const Duration(milliseconds: 4000)).then((_) {
                    if (!isEditing && toastMode == 4) toastMode = 0;
                  });

                  setState(() => isEditing = false);
                },
                child: ExtendedImage.memory(
                  widget.bytes,
                  fit: BoxFit.contain,
                  width: 300,
                  height: 300,
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (ExtendedImageState state) {
                    return GestureConfig(
                      minScale: 0.4,
                      animationMinScale: 0.25,
                      maxScale: 3.0,
                      animationMaxScale: 3.5,
                      speed: 1.0,
                      inertialSpeed: 100.0,
                      initialScale: 2.25,
                      inPageView: false,
                      initialAlignment: InitialAlignment.center,
                    );
                  },
                ),
              ),
            ),
            IgnorePointer(
              child: isEditing
                  ? SizedBox(
                      width: dimensions!['width'],
                      height: dimensions!['height'],
                      child: Stack(
                        children: [
                          Positioned(
                            left: dimensions!['inner-distance-left'],
                            top: dimensions!['inner-distance-top'],
                            child: DottedBorder(
                              borderType: BorderType.Circle,
                              padding: const EdgeInsets.all(5),
                              color: Colors.white,
                              strokeWidth: 2.5,
                              dashPattern: const [10, 5],
                              child: Container(
                                width: dimensions!['inner-radius'],
                                height: dimensions!['inner-radius'],
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: dimensions!['width'],
                      height: dimensions!['height'],
                    ),
            ),
            GestureDetector(
              onTap: () {
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
                        "Download the Bible Champs application now. Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child. \n${DatabaseService().dynamicUrl}",
                  );
                });
              },
              child: isEditing
                  ? SizedBox(
                      width: dimensions!['width'],
                      height: dimensions!['height'],
                    )
                  : SizedBox(
                      width: dimensions!['width'],
                      height: dimensions!['height'],
                      child: Stack(
                        children: [
                          imageFile ?? const SizedBox(),
                          Positioned(
                            left: dimensions!['text-distance-left'],
                            top: dimensions!['text-distance-top'],
                            child: Container(
                              alignment: Alignment.center,
                              width: dimensions!['text-width'],
                              height: dimensions!['text-height'],
                              child: Text(
                                '${DatabaseService().firstname} ${DatabaseService().lastname}',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 7.5, left: 7.5),
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
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
                        if (!isEditing) {
                          toastMode = 5;

                          Fluttertoast.showToast(
                            msg: 'Pinch, zoom and drag face into the circle',
                            toastLength: Toast.LENGTH_LONG,
                          );

                          Future.delayed(const Duration(milliseconds: 4000))
                              .then((_) {
                            if (isEditing && toastMode == 5) {
                              toastMode = 6;

                              Fluttertoast.showToast(
                                msg: 'Tap image when ready',
                                toastLength: Toast.LENGTH_LONG,
                              );
                            }
                          });

                          Future.delayed(const Duration(milliseconds: 8000))
                              .then((_) {
                            if (isEditing && toastMode == 6) toastMode = 0;
                          });

                          setState(() => isEditing = true);
                        } else {
                          isEditing =
                              false; // prevent toasts after editor closes
                          Navigator.pop(context);
                        }
                      },
                      child: const SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: !isEditing
                  ? Padding(
                      padding: const EdgeInsets.only(top: 7.5, right: 7.5),
                      child: ClipOval(
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(
                                  '${DatabaseService().downloadPath}/images/button-home.png')),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                            ),
                            onPressed: () {
                              isEditing =
                                  false; // prevent toasts after editor closes
                              Navigator.pop(context);
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptor);
    super.dispose();
  }
}
