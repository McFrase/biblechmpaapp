import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PreteensWordSearchGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreteensWordSearchGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreteensWordSearchGameState createState() => PreteensWordSearchGameState();
}

class PreteensWordSearchGameState extends GameState<PreteensWordSearchGame> {
  PreteensWordSearchGameState() : super('preteens', 'wordsearch');

  List? boxes;
  List? colors;
  List? colorsBackup;
  List? candidates;
  List? words;
  List completed = [];
  int xBoxes = 13;
  int yBoxes = 8;
  bool isDragging = false;

  void evaluateGame() {
    selected = true;

    if (((completed.length / words!.length) * 100) >= 50) {
      evaluate(true, ((completed.length / words!.length) * 250).round());
    } else {
      evaluate(false);
    }
  }

  Widget getHintWord(int index) {
    return Text(
      index < words!.length ? words![index] : '',
      style: TextStyle(
        fontSize: 16,
        color: index < words!.length && !completed.contains(words![index])
            ? Colors.black
            : Colors.red,
        decorationColor: Colors.red,
        decoration: index < words!.length && !completed.contains(words![index])
            ? TextDecoration.none
            : TextDecoration.lineThrough,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget getGridBox(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: isDragging
          ? DragTarget(onWillAccept: (data) {
              if (!candidates!.contains(index)) {
                candidates!.add(index);
                colors![index] = Colors.orange;
                setState(() {});
              }
              return false;
            }, builder: (context, candidateData, rejectedData) {
              return getText(index);
            })
          : Draggable(
              child: getText(index),
              onDragStarted: () {
                isDragging = true;
                colorsBackup = List.from(colors!);
                colors![index] = Colors.orange;
                candidates = [];
                candidates!.add(index);
                setState(() {});
              },
              onDraggableCanceled: (velocity, offset) {
                String candidate = '';

                for (var value in candidates!) {
                  candidate += boxes![value];
                }

                if (!completed.contains(candidate)) {
                  bool correct = false;

                  for (var value in words!) {
                    if (value == candidate) correct = true;
                  }

                  if (correct && isLinear()) {
                    completed.add(candidate);

                    for (var value in candidates!) {
                      colors![value] = Colors.green;
                    }

                    AudioService().playChime();

                    if (listEquals(words!..sort(), completed..sort())) {
                      evaluateGame();
                    }
                  } else {
                    AudioService().playBuzz();
                    colors = List.from(colorsBackup!);
                  }
                } else {
                  AudioService().playBuzz();
                  colors = List.from(colorsBackup!);
                }

                isDragging = false;
                setState(() {});
              },
              childWhenDragging: getText(index),
              feedback: const SizedBox(),
            ),
    );
  }

  Widget getText(index) {
    return Container(
      alignment: Alignment.center,
      color: colors![index],
      child: Text(
        boxes![index],
        style: TextStyle(
          color: Colors.white,
          fontSize:
              ((MediaQuery.of(context).size.height * 0.7) / yBoxes) * 0.75,
        ),
      ),
    );
  }

  bool isLinear() {
    bool reverse = candidates!.first > candidates!.last;
    int first = reverse ? candidates!.last : candidates!.first;
    int last = reverse ? candidates!.first : candidates!.last;
    bool xAxis = first < (((last / xBoxes).floor() + 1) * xBoxes) &&
        first >= ((last / xBoxes).floor() * xBoxes);
    bool yAxis = first % xBoxes == last % xBoxes;

    if (!xAxis && !yAxis) return false;
    if (reverse) candidates = List.from(candidates!.reversed);

    for (MapEntry e in candidates!.asMap().entries) {
      if (xAxis) {
        bool check = first < (((e.value / xBoxes).floor() + 1) * xBoxes) &&
            first >= ((e.value / xBoxes).floor() * xBoxes);
        if (!check) return false;
      }

      if (yAxis) {
        if (e.value % xBoxes != first % xBoxes) return false;
      }
    }

    return true;
  }

  @override
  Widget nextGame() {
    return PreteensWordSearchGame(
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

    max = 4;
    value = 250;
    countdown = 120;
    background = 'bg-9.jpg';
    boxes = []..length = xBoxes * yBoxes;
    colors = List.filled(xBoxes * yBoxes, Colors.blue[900]);
    words = question!['words'].split(' ')..shuffle();

    question!['puzzle'].split('').asMap().forEach((key, value) {
      boxes![key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = JelloIn(
      delay: const Duration(milliseconds: 500),
      child: SizedBox(
        width: ((MediaQuery.of(context).size.height * 0.7) / yBoxes) * xBoxes,
        height: MediaQuery.of(context).size.height * 0.7,
        child: GridView.count(
          crossAxisCount: xBoxes,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(xBoxes * yBoxes, (index) {
            return getGridBox(index);
          }),
        ),
      ),
    );

    fab = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          heroTag: 'next',
          tooltip: 'Next',
          onPressed: !selected ? () => evaluateGame() : null,
          child: const FaIcon(
            FontAwesomeIcons.arrowRight,
            color: Colors.white,
          ),
        ),
        if (!hideHint)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: FloatingActionButton(
              heroTag: 'help',
              tooltip: 'Help',
              backgroundColor: Colors.green,
              onPressed: !selected
                  ? () {
                      UiService().showAlert(
                        context,
                        title: question!['title'],
                        desc: 'Find the following words:',
                        content: Column(
                          children: [
                            const SizedBox(height: 10),
                            for (int i = 0; i < (words!.length / 3); i++)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  for (int j = 0; j < 3; j++)
                                    SizedBox(
                                      width: 150,
                                      child: getHintWord((i * 3) + j),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                  : null,
              child: const FaIcon(
                IconDataSolid(0xf0eb),
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    return super.build(context);
  }
}
