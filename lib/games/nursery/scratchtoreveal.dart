import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NurseryScratchToRevealGame extends StatefulWidget {
  const NurseryScratchToRevealGame({Key? key}) : super(key: key);

  @override
  NurseryScratchToRevealGameState createState() =>
      NurseryScratchToRevealGameState();
}

class NurseryScratchToRevealGameState
    extends GameState<NurseryScratchToRevealGame> {
  NurseryScratchToRevealGameState() : super('nursery', 'scratchtoreveal');

  List? boxes;
  Image? image;
  Timer? infoTimer;

  int xBoxes = 25;
  int yBoxes = 18;
  double size = 0;
  bool started = false;
  bool fabShown = false;
  bool completed = false;
  bool isDragging = false;
  AnimationController? infoAnimationController;
  AnimationController? fabAnimationController;

  void evaluateGame() async {
    if (!started) {
      infoAnimationController!.reverse();
      AudioService().reduceMusic();
      started = true;
    }

    if (completed == true) return;

    // 90% done
    if ((boxes!.where((n) => n == 1).length / (xBoxes * yBoxes)) < 0.9) return;

    completed = true;

    AudioService().playChime();

    await Future.delayed(const Duration(milliseconds: 1000));

    UiService().showAlert(
      context,
      imagePath:
          '${DatabaseService().downloadPath}/images/accolades-nursery-${accolade(true)}.png',
      buttonText: 'YAY!',
      onPop: () {
        setState(() => fabShown = true);
        fabAnimationController!.forward();
      },
    );
  }

  bool processCenterBox(int index) {
    if (boxes![index] != 1) {
      boxes![index] = 1;
      return true;
    }

    return false;
  }

  bool processRightBox(int index) {
    if (boxes![index + 1] != 1) {
      boxes![index + 1] = 1;
      return true;
    }

    return false;
  }

  bool processLeftBox(int index) {
    if (boxes![index - 1] != 1) {
      boxes![index - 1] = 1;
      return true;
    }

    return false;
  }

  bool processBottomBox(int index) {
    if (boxes![index + xBoxes] != 1) {
      boxes![index + xBoxes] = 1;
      return true;
    }

    return false;
  }

  bool processTopBox(int index) {
    if (boxes![index - xBoxes] != 1) {
      boxes![index - xBoxes] = 1;
      return true;
    }

    return false;
  }

  bool processBottomRightBox(int index) {
    if (boxes![(index + xBoxes) + 1] != 1) {
      boxes![(index + xBoxes) + 1] = 1;
      return true;
    }

    return false;
  }

  bool processBottomLeftBox(int index) {
    if (boxes![(index + xBoxes) - 1] != 1) {
      boxes![(index + xBoxes) - 1] = 1;
      return true;
    }

    return false;
  }

  bool processTopRightBox(int index) {
    if (boxes![(index - xBoxes) + 1] != 1) {
      boxes![(index - xBoxes) + 1] = 1;
      return true;
    }

    return false;
  }

  bool processTopLeftBox(int index) {
    if (boxes![(index - xBoxes) - 1] != 1) {
      boxes![(index - xBoxes) - 1] = 1;
      return true;
    }

    return false;
  }

  bool processTopLeftGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processBottomRightBox(index)) processed = true;

    return processed;
  }

  bool processTopRightGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processBottomLeftBox(index)) processed = true;

    return processed;
  }

  bool processBottomLeftGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processTopRightBox(index)) processed = true;

    return processed;
  }

  bool processBottomRightGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processTopLeftBox(index)) processed = true;

    return processed;
  }

  bool processTopRowGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processBottomRightBox(index)) processed = true;
    if (processBottomLeftBox(index)) processed = true;

    return processed;
  }

  bool processBottomRowGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processTopRightBox(index)) processed = true;
    if (processTopLeftBox(index)) processed = true;

    return processed;
  }

  bool processLeftColumnGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processBottomRightBox(index)) processed = true;
    if (processTopRightBox(index)) processed = true;

    return processed;
  }

  bool processRightColumnGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processBottomLeftBox(index)) processed = true;
    if (processTopLeftBox(index)) processed = true;

    return processed;
  }

  bool processSurroundedGridBox(int index) {
    bool processed = false;

    if (processCenterBox(index)) processed = true;
    if (processRightBox(index)) processed = true;
    if (processLeftBox(index)) processed = true;
    if (processBottomBox(index)) processed = true;
    if (processTopBox(index)) processed = true;
    if (processBottomRightBox(index)) processed = true;
    if (processBottomLeftBox(index)) processed = true;
    if (processTopRightBox(index)) processed = true;
    if (processTopLeftBox(index)) processed = true;

    return processed;
  }

  bool processGridBox(int index) {
    bool? processed;

    if (index == 0) {
      processed = processTopLeftGridBox(index);
    } else if (index == xBoxes - 1) {
      processed = processTopRightGridBox(index);
    } else if (index == (xBoxes * yBoxes) - xBoxes) {
      processed = processBottomLeftGridBox(index);
    } else if (index == (xBoxes * yBoxes) - 1) {
      processed = processBottomRightGridBox(index);
    } else if (index < xBoxes) {
      processed = processTopRowGridBox(index);
    } else if (index > (xBoxes * yBoxes) - xBoxes) {
      processed = processBottomRowGridBox(index);
    } else if (index % xBoxes == 0) {
      processed = processLeftColumnGridBox(index);
    } else if (index % xBoxes == xBoxes - 1) {
      processed = processRightColumnGridBox(index);
    } else {
      processed = processSurroundedGridBox(index);
    }

    if (processed == true) {
      AudioService().playPop();
      setState(() {});
      evaluateGame();
    }

    return processed;
  }

  Widget buildGrid(index) {
    return SizedBox(
      child: completed
          ? const SizedBox()
          : isDragging
              ? DragTarget(onWillAccept: (data) {
                  processGridBox(index);

                  return false;
                }, builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: size,
                    height: size,
                    color: boxes![index] == 1
                        ? Colors.transparent
                        : Colors.blue[900],
                  );
                })
              : Draggable(
                  child: GestureDetector(
                    onTap: () => processGridBox(index),
                    child: Container(
                      width: size,
                      height: size,
                      color: boxes![index] == 1
                          ? Colors.transparent
                          : Colors.blue[900],
                    ),
                  ),
                  onDragStarted: () {
                    processGridBox(index);
                    setState(() => isDragging = true);
                  },
                  onDraggableCanceled: (velocity, offset) {
                    setState(() => isDragging = false);
                  },
                  feedback: Transform.translate(
                    offset: Offset(
                      -(size * 5) / 2.5,
                      -(size * 5) / 2.5,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.75,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: CircleBorder(),
                            ),
                          ),
                        ),
                        Image.file(
                          File(
                              '${DatabaseService().downloadPath}/images/glitter.gif'),
                          width: size * 5,
                        ),
                      ],
                    ),
                  ),
                  childWhenDragging: Container(
                    width: size,
                    height: size,
                    color: Colors.transparent,
                  ),
                ),
    );
  }

  @override
  Widget nextGame() {
    return const NurseryScratchToRevealGame();
  }

  @override
  void initState() {
    super.initState();

    background = 'bg-8.jpg';
    boxes = List.filled(xBoxes * yBoxes, 0);

    Future(() {
      setState(() {
        image = Image.file(
          File(
              "${DatabaseService().downloadPath}/gamepictures/${question!['image']}"),
          height: MediaQuery.of(context).size.height * 0.70,
        );

        size = image!.height! / yBoxes;
      });
    });

    infoTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!started) {
        infoAnimationController!.forward();
        AudioService().playShockWave();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          foregroundDecoration: BoxDecoration(
            color: completed ? Colors.transparent : Colors.grey,
            backgroundBlendMode: BlendMode.saturation,
          ),
          child: image,
        ),
        SizedBox(
          height: size * yBoxes,
          child: AspectRatio(
            aspectRatio: 504 / 360,
            child: GridView.count(
              crossAxisCount: xBoxes,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(xBoxes * yBoxes, (index) {
                return buildGrid(index);
              }),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: JelloIn(
            animate: false,
            controller: (controller) => infoAnimationController = controller,
            child: Container(
              color: Colors.blue[900],
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              child: const Text(
                "SCRATCH TO SEE WHAT'S HIDDEN!",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    fab = Bounce(
      animate: false,
      from: 200,
      controller: (controller) => fabAnimationController = controller,
      child: Visibility(
        visible: fabShown,
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => next(),
          child: const FaIcon(
            FontAwesomeIcons.arrowRight,
            color: Colors.white,
          ),
        ),
      ),
    );

    return super.build(context);
  }

  @override
  void dispose() {
    infoTimer?.cancel();
    super.dispose();
  }
}
