import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PreschoolJigsawPuzzleGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreschoolJigsawPuzzleGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreschoolJigsawPuzzleGameState createState() =>
      PreschoolJigsawPuzzleGameState();
}

class PreschoolJigsawPuzzleGameState
    extends GameState<PreschoolJigsawPuzzleGame> {
  PreschoolJigsawPuzzleGameState() : super('preschool', 'jigsawpuzzle');

  File? file;
  List canvas = [null, null, null, null];
  List options = [1, 2, 3, 4]..shuffle();

  void evaluateGame() {
    selected = true;

    if (canvas[0] == 1 && canvas[1] == 2 && canvas[2] == 3 && canvas[3] == 4) {
      evaluate(true);
    } else {
      evaluate(false);
    }
  }

  List<Widget> buildCanvas() {
    return List.generate(4, (index) {
      return canvas[index] == null
          ? DragTarget<Map>(onWillAccept: (data) {
              return true;
            }, onAccept: (data) {
              if (data['id'] == 'canvas') canvas[data['from']] = null;
              if (data['id'] == 'options') options[data['from']] = null;
              canvas[index] = data['data'];
              setState(() {});
            }, builder: (context, candidateData, rejectedData) {
              return Container(
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            })
          : Draggable<Map>(
              child: SizedBox(
                width: (MediaQuery.of(context).size.height * 0.70) / 2,
                height: (MediaQuery.of(context).size.height * 0.70) / 2,
                child: getClip(canvas[index], 1),
              ),
              data: {
                'from': index,
                'id': 'canvas',
                'data': canvas[index],
              },
              feedback: SizedBox(
                width: (MediaQuery.of(context).size.height * 0.70) / 2,
                height: (MediaQuery.of(context).size.height * 0.70) / 2,
                child: getClip(canvas[index], 1),
              ),
              childWhenDragging: Container(
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
    });
  }

  List<Widget> buildOptions() {
    return List.generate(4, (index) {
      return options[index] == null
          ? DragTarget<Map>(onWillAccept: (data) {
              return true;
            }, onAccept: (data) {
              if (data['id'] == 'canvas') canvas[data['from']] = null;
              if (data['id'] == 'options') options[data['from']] = null;
              options[index] = data['data'];
              setState(() {});
            }, builder: (context, candidateData, rejectedData) {
              return Container(
                width: (MediaQuery.of(context).size.height * 0.70) / 4,
                height: (MediaQuery.of(context).size.height * 0.70) / 4,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            })
          : Draggable<Map>(
              child: SizedBox(
                width: (MediaQuery.of(context).size.height * 0.70) / 4,
                height: (MediaQuery.of(context).size.height * 0.70) / 4,
                child: getClip(options[index], 0.5),
              ),
              data: {
                'from': index,
                'id': 'options',
                'data': options[index],
              },
              feedback: SizedBox(
                width: (MediaQuery.of(context).size.height * 0.70) / 2,
                height: (MediaQuery.of(context).size.height * 0.70) / 2,
                child: getClip(options[index], 1),
              ),
              childWhenDragging: Container(
                width: (MediaQuery.of(context).size.height * 0.70) / 4,
                height: (MediaQuery.of(context).size.height * 0.70) / 4,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget? getClip(index, scale) {
    switch (index) {
      case 1:
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: getImageContainer(scale),
            ),
          ],
        );
      case 2:
        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: getImageContainer(scale),
            ),
          ],
        );
      case 3:
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: getImageContainer(scale),
            ),
          ],
        );
      case 4:
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: getImageContainer(scale),
            ),
          ],
        );
      default:
        return null;
    }
  }

  Widget getImageContainer(scale) {
    return Container(
      width: (MediaQuery.of(context).size.height * 0.70) * scale,
      height: (MediaQuery.of(context).size.height * 0.70) * scale,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(file!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget nextGame() {
    return PreschoolJigsawPuzzleGame(
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
    background = 'bg-13.jpg';
    file = File(
        "${DatabaseService().downloadPath}/gamepictures/${question!['image']}");
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElasticInLeft(
          delay: const Duration(milliseconds: 500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.height * 0.70,
              height: MediaQuery.of(context).size.height * 0.70,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                physics: const NeverScrollableScrollPhysics(),
                children: buildCanvas(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        ElasticInRight(
          delay: const Duration(milliseconds: 1000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: buildOptions(),
          ),
        ),
      ],
    );

    fab = FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: !selected ? () => evaluateGame() : null,
      child: const FaIcon(
        FontAwesomeIcons.arrowRight,
        color: Colors.white,
      ),
    );

    return super.build(context);
  }
}
