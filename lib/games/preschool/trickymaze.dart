import 'dart:io';

import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PreschoolTrickyMazeGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreschoolTrickyMazeGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreschoolTrickyMazeGameState createState() => PreschoolTrickyMazeGameState();
}

class PreschoolTrickyMazeGameState extends GameState<PreschoolTrickyMazeGame> {
  PreschoolTrickyMazeGameState() : super('preschool', 'trickymaze');

  List? puzzle;
  List? dragState;
  int xBoxes = 9;
  int yBoxes = 7;
  int dragCurrent = 0;
  bool done = false;
  bool stopped = true;
  bool isDragging = false;
  BehaviorSubject<bool> stream = BehaviorSubject<bool>();

  void evaluateGame(bool completed) {
    selected = true;

    int count;
    int pathCount = 0;
    int rightCount = 0;
    int wrongCount = 0;

    dragState!.asMap().forEach((key, value) {
      if (value == 1) {
        pathCount++;

        if (puzzle![key]['type'] != 1) wrongCount++;
      }
    });

    puzzle!.asMap().forEach((key, value) {
      if (value['type'] == 1) rightCount++;
    });

    if (completed) {
      count = rightCount - wrongCount;
      evaluate(true, ((count / dragState!.length) * 100).round());
    } else {
      count = pathCount - wrongCount;
      evaluate(false);
    }
  }

  Widget buildGoalPost() {
    return Positioned(
      bottom: 5,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File('${DatabaseService().downloadPath}/images/net.png'),
              width: (MediaQuery.of(context).size.height * 0.70 / yBoxes) * 1.1,
            ),
            done
                ? Image.file(
                    File('${DatabaseService().downloadPath}/images/ball.png'),
                    width: MediaQuery.of(context).size.height * 0.70 / yBoxes,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildTopBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(xBoxes, (index) {
        return Container(
          height: 10,
          width: MediaQuery.of(context).size.height * 0.70 / yBoxes,
          decoration: BoxDecoration(
            border: Border(
              bottom: index != 0
                  ? const BorderSide(
                      color: Colors.white,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: DragTarget(
            onWillAccept: (data) {
              stream.add(false);
              isDragging = false;
              setState(() {});

              return false;
            },
            builder: (context, candidateData, rejectedData) => const SizedBox(),
          ),
        );
      }),
    );
  }

  Widget buildBottomBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(xBoxes, (index) {
        return Container(
          height: 10,
          width: MediaQuery.of(context).size.height * 0.70 / yBoxes,
          decoration: BoxDecoration(
            border: Border(
              top: index != xBoxes - 1
                  ? const BorderSide(
                      color: Colors.white,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: DragTarget(
            onWillAccept: (data) {
              stream.add(false);
              isDragging = false;
              setState(() {});

              return false;
            },
            builder: (context, candidateData, rejectedData) => const SizedBox(),
          ),
        );
      }),
    );
  }

  Widget buildLeftBlock() {
    return Column(
      children: List.generate(yBoxes, (index) {
        return Container(
          width: 10,
          height: MediaQuery.of(context).size.height * 0.70 / yBoxes,
          decoration: BoxDecoration(
            border: Border(
              right: index != 0
                  ? const BorderSide(
                      color: Colors.white,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: DragTarget(
            onWillAccept: (data) {
              stream.add(false);
              isDragging = false;
              setState(() {});

              return false;
            },
            builder: (context, candidateData, rejectedData) => const SizedBox(),
          ),
        );
      }),
    );
  }

  Widget buildRightBlock() {
    return Column(
      children: List.generate(yBoxes, (index) {
        return Container(
          width: 10,
          height: MediaQuery.of(context).size.height * 0.70 / yBoxes,
          decoration: BoxDecoration(
            border: Border(
              left: index != yBoxes - 1
                  ? const BorderSide(
                      color: Colors.white,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: DragTarget(
            onWillAccept: (data) {
              stream.add(false);
              isDragging = false;
              setState(() {});

              return false;
            },
            builder: (context, candidateData, rejectedData) => const SizedBox(),
          ),
        );
      }),
    );
  }

  Widget buildMaze() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: AspectRatio(
        aspectRatio: xBoxes / yBoxes,
        child: GridView.count(
          crossAxisCount: xBoxes,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(xBoxes * yBoxes, (index) {
            return buildMazeBlock(index);
          }),
        ),
      ),
    );
  }

  Widget buildMazeBlock(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: puzzle![index]['top'] == 0
              ? const BorderSide(
                  color: Colors.white,
                  width: 1,
                )
              : BorderSide.none,
          bottom: puzzle![index]['bottom'] == 0
              ? const BorderSide(
                  color: Colors.white,
                  width: 1,
                )
              : BorderSide.none,
          left: puzzle![index]['left'] == 0
              ? const BorderSide(
                  color: Colors.white,
                  width: 1,
                )
              : BorderSide.none,
          right: puzzle![index]['right'] == 0
              ? const BorderSide(
                  color: Colors.white,
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: dragCurrent == index && !selected
          ? Draggable(
              child: dragCurrent == index && !stream.value
                  ? Image.file(
                      File('${DatabaseService().downloadPath}/images/ball.png'))
                  : const SizedBox(),
              onDragStarted: () {
                isDragging = true;
                setState(() {});
                stream.add(true);
              },
              onDraggableCanceled: (velocity, offset) {
                if (isDragging) {
                  stream.add(false);
                  isDragging = false;
                  setState(() {});
                }

                if (dragCurrent == (xBoxes * yBoxes) - 1) {
                  done = true;

                  AudioService().playChime();
                  evaluateGame(true);
                }
              },
              childWhenDragging: const SizedBox(),
              feedback: StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  return stream.value
                      ? Image.file(
                          File(
                              '${DatabaseService().downloadPath}/images/ball.png'),
                          width: MediaQuery.of(context).size.height *
                              0.70 /
                              yBoxes,
                        )
                      : const SizedBox();
                },
              ),
            )
          : DragTarget(
              onWillAccept: (data) {
                if (isDragging) {
                  int side = 0;

                  if (dragCurrent == index - xBoxes) {
                    side = 1;
                  } // is below
                  if (dragCurrent == index + xBoxes) {
                    side = 2;
                  } // is on top
                  if (dragCurrent == index + 1) {
                    side = 3;
                  } // is to the left
                  if (dragCurrent == index - 1) {
                    side = 4;
                  } // is to the right

                  if ((side == 1 && puzzle![index]['top'] == 1) ||
                      (side == 2 && puzzle![index]['bottom'] == 1) ||
                      (side == 3 && puzzle![index]['right'] == 1) ||
                      (side == 4 && puzzle![index]['left'] == 1)) {
                    dragCurrent = index;
                    dragState![index] = 1;
                    setState(() {});
                  } else {
                    stream.add(false);
                    isDragging = false;
                    setState(() {});
                  }
                }

                return false;
              },
              builder: (context, candidateData, rejectedData) =>
                  const SizedBox(),
            ),
    );
  }

  @override
  Widget nextGame() {
    return PreschoolTrickyMazeGame(
      index: index! + 1,
      accumulator: accumulator,
      valid: valid,
    );
  }

  @override
  void initState() {
    super.initState();

    initializeGame(
      widget.index,
      widget.valid,
      widget.accumulator,
      widget.randomMode,
    );

    max = 10;
    value = 100;
    background = 'field.jpg';
    dragState = List.filled(xBoxes * yBoxes, 0);
    puzzle = question!['puzzle'].split(' ').map((value) {
      List specs = value.split('|');

      return {
        'top': int.parse(specs[0]),
        'right': int.parse(specs[1]),
        'bottom': int.parse(specs[2]),
        'left': int.parse(specs[3]),
        'type': int.parse(specs[4]),
      };
    }).toList();

    stream.add(false);
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = SizedBox(
      width:
          ((MediaQuery.of(context).size.height * 0.7) / yBoxes) * (xBoxes + 1),
      height: ((MediaQuery.of(context).size.height * 0.7) / yBoxes) * yBoxes,
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildGoalPost(),
          Column(
            children: [
              buildTopBlock(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLeftBlock(),
                  buildMaze(),
                  buildRightBlock(),
                ],
              ),
              buildBottomBlock(),
            ],
          ),
        ],
      ),
    );

    fab = FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: !selected ? () => evaluateGame(false) : null,
      child: const FaIcon(
        FontAwesomeIcons.arrowRight,
        color: Colors.white,
      ),
    );

    return super.build(context);
  }
}
