import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:painter/painter.dart';
import 'package:screenshot/screenshot.dart';

class NurseryColoringGameGame extends StatefulWidget {
  const NurseryColoringGameGame({Key? key}) : super(key: key);

  @override
  NurseryColoringGameGameState createState() => NurseryColoringGameGameState();
}

class NurseryColoringGameGameState extends GameState<NurseryColoringGameGame> {
  NurseryColoringGameGameState() : super('nursery', 'coloringgame');

  Image? image;
  AnimationController? eraserSizeAnimationController;
  AnimationController? drawColorAnimationController;

  PainterController painterController = PainterController();
  ScreenshotController screenshotController = ScreenshotController();

  List drawColors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.blueGrey,
    Colors.brown
  ];

  void undoPainting() {
    if (painterController.isEmpty) {
      Fluttertoast.showToast(msg: 'Nothing to undo');
    } else {
      painterController.undo();
    }
  }

  Widget buildCanvas() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Screenshot(
        controller: screenshotController,
        child: (image != null)
            ? Stack(
                children: [
                  GestureDetector(
                    onPanDown: (details) {
                      eraserSizeAnimationController!.reverse();
                      drawColorAnimationController!.reverse();
                    },
                    child: SizedBox(
                      height: image?.height,
                      child: AspectRatio(
                        aspectRatio: 504 / 360,
                        child: Painter(painterController),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: image,
                  ),
                  SizedBox(
                    height: image?.height,
                    child: AspectRatio(
                      aspectRatio: 504 / 360,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SlideInUp(
                          animate: false,
                          controller: (controller) =>
                              eraserSizeAnimationController = controller,
                          child: Container(
                            width: 275,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.75),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    painterController.thickness =
                                        5.0 * (index + 1);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 5.0 * (index + 1),
                                      height: 5.0 * (index + 1),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        color: painterController.thickness ==
                                                5.0 * (index + 1)
                                            ? Colors.black
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: image?.height,
                    child: AspectRatio(
                      aspectRatio: 504 / 360,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SlideInUp(
                          animate: false,
                          controller: (controller) =>
                              drawColorAnimationController = controller,
                          child: Container(
                            width: 225,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.75),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        painterController.drawColor =
                                            drawColors[index];
                                        setState(() {});
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: painterController.drawColor ==
                                                  drawColors[index]
                                              ? 40
                                              : 30,
                                          height: painterController.drawColor ==
                                                  drawColors[index]
                                              ? 40
                                              : 30,
                                          decoration: BoxDecoration(
                                            color: drawColors[index],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    index += 4;
                                    return GestureDetector(
                                      onTap: () {
                                        painterController.drawColor =
                                            drawColors[index];
                                        setState(() {});
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: painterController.drawColor ==
                                                  drawColors[index]
                                              ? 40
                                              : 30,
                                          height: painterController.drawColor ==
                                                  drawColors[index]
                                              ? 40
                                              : 30,
                                          decoration: BoxDecoration(
                                            color: drawColors[index],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }

  Widget buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-brush-${(painterController.thickness == 5.0 && painterController.eraseMode == false) ? 1 : 2}.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  painterController.eraseMode = false;
                  painterController.thickness = 5.0;

                  setState(() {});
                  eraserSizeAnimationController!.reverse();
                  drawColorAnimationController!.isCompleted
                      ? drawColorAnimationController!.reverse()
                      : drawColorAnimationController!.forward();
                },
                child: const SizedBox(),
              ),
            ),
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-eraser-${(painterController.eraseMode == true) ? 1 : 2}.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  if (painterController.eraseMode == false) {
                    painterController.eraseMode = true;
                    painterController.thickness = 15.0;

                    setState(() {});
                  }
                  drawColorAnimationController!.reverse();
                  eraserSizeAnimationController!.isCompleted
                      ? eraserSizeAnimationController!.reverse()
                      : eraserSizeAnimationController!.forward();
                },
                child: const SizedBox(),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-bugbrush-${(painterController.thickness == 15.0 && painterController.eraseMode == false) ? 1 : 2}.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  painterController.eraseMode = false;
                  painterController.thickness = 15.0;

                  setState(() {});
                  eraserSizeAnimationController!.reverse();
                  drawColorAnimationController!.isCompleted
                      ? drawColorAnimationController!.reverse()
                      : drawColorAnimationController!.forward();
                },
                child: const SizedBox(),
              ),
            ),
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-undo-2.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  painterController.undo();
                },
                child: const SizedBox(),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-roller-${(painterController.thickness == 25.0 && painterController.eraseMode == false) ? 1 : 2}.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  painterController.eraseMode = false;
                  painterController.thickness = 25.0;

                  setState(() {});
                  eraserSizeAnimationController!.reverse();
                  drawColorAnimationController!.isCompleted
                      ? drawColorAnimationController!.reverse()
                      : drawColorAnimationController!.forward();
                },
                child: const SizedBox(),
              ),
            ),
            Container(
              width: 50,
              height: 46.88,
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/button-delete-2.png')),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  UiService().showAlert(
                    context,
                    title: 'Are you sure?',
                    desc:
                        "This will erase everything on the Canvas, you'll lose any progress made so far!",
                    isWarning: true,
                    hasCancelButton: true,
                    cancelButtonText: 'NO',
                    cancelButtonColor: Colors.orange,
                    buttonText: 'YES ',
                    buttonColor: Colors.red,
                    onClick: () => painterController.clear(),
                  );
                },
                child: const SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget nextGame() {
    return const NurseryColoringGameGame();
  }

  @override
  void initState() {
    super.initState();

    background = 'bg-12.jpg';
    painterController.thickness = 5.0;
    painterController.drawColor = Colors.blue;
    painterController.backgroundColor = Colors.white;

    Future(() {
      setState(() {
        image = Image.file(
          File(
              "${DatabaseService().downloadPath}/coloringgame/${question!['image']}"),
          height: MediaQuery.of(context).size.height * 0.70,
        );
      });
    });

    saveButtonOnPressed = () {
      screenshotController
          .captureAndSave(
        DatabaseService().galleryPath,
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
        fileName: '${DateTime.now().millisecondsSinceEpoch}.png',
      )
          .then((String? image) {
        UiService().showAlert(
          context,
          isSuccess: true,
          title: 'Saved to Gallery',
        );
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElasticInLeft(
          delay: const Duration(milliseconds: 500),
          child: buildCanvas(),
        ),
        const SizedBox(width: 25),
        ElasticInRight(
          delay: const Duration(milliseconds: 1000),
          child: buildControls(),
        ),
      ],
    );

    fab = FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: () => next(),
      child: const FaIcon(
        FontAwesomeIcons.arrowRight,
        color: Colors.white,
      ),
    );

    return super.build(context);
  }

  @override
  void dispose() {
    painterController.dispose();
    eraserSizeAnimationController?.dispose();
    drawColorAnimationController?.dispose();
    super.dispose();
  }
}
