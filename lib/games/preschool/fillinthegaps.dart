import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class PreschoolFillInTheGapsGame extends StatefulWidget {
  final int? index;
  final int? valid;
  final int? accumulator;
  final bool? randomMode;

  const PreschoolFillInTheGapsGame({
    Key? key,
    this.index,
    this.valid,
    this.accumulator,
    this.randomMode,
  }) : super(key: key);

  @override
  PreschoolFillInTheGapsGameState createState() =>
      PreschoolFillInTheGapsGameState();
}

class PreschoolFillInTheGapsGameState
    extends GameState<PreschoolFillInTheGapsGame> {
  PreschoolFillInTheGapsGameState() : super('preschool', 'fillinthegaps');

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void evaluateGame() {
    selected = true;
    FocusScope.of(context).requestFocus(FocusNode());

    if (formKey.currentState!.validate()) {
      evaluate(true);
    } else {
      evaluate(false);
    }
  }

  List<Widget> getOptions() {
    List temp = question!['options'].trim().split(' ');

    return temp.map<Widget>((value) {
      return Container(
        alignment: Alignment.center,
        width: 22.5,
        height: 22.5,
        margin: const EdgeInsets.fromLTRB(5, 5, 0, 5),
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }).toList();
  }

  Widget gap(no) {
    return Container(
      padding: EdgeInsets.zero,
      width: 25,
      height: 20,
      child: TextFormField(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: -30.0),
          counterText: '',
          errorStyle: TextStyle(
            height: 0,
            fontSize: 0,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.green,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.green,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
        ),
        textCapitalization: TextCapitalization.characters,
        maxLength: 1,
        validator: (value) {
          List gaps = question!['gaps'].trim().split(' ');
          String gap = gaps[no];

          if (value?.trim().toLowerCase() == gap.toLowerCase()) {
            return null;
          } else {
            return 'wrong';
          }
        },
        style: const TextStyle(
          fontSize: 25,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(-1.25, 1.25),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget gapify() {
    int x = 0;
    String str = question!['question'].replaceAll('*', '|<>|');
    List arr = str.split('|');
    List<Widget> newArr = [];

    for (var value in arr) {
      if (value == '<>') {
        newArr.add(gap(x));
        x++;
      } else {
        newArr.add(Text(
          value,
          style: const TextStyle(
            fontSize: 25,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(-1.25, 1.25),
              ),
            ],
          ),
        ));
      }
    }

    return Wrap(
      spacing: 0,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: newArr,
    );
  }

  @override
  Widget nextGame() {
    return PreschoolFillInTheGapsGame(
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
    hasHint = true;
    background = 'bg-5.jpg';
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElasticInDown(
          delay: const Duration(milliseconds: 500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(
                      '${DatabaseService().downloadPath}/images/bg-text.jpg')),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              width: 250,
              height: 185,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: gapify(),
              ),
            ),
          ),
        ),
        ElasticInUp(
          delay: const Duration(milliseconds: 1000),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: const Size(240, 40),
              ),
              onPressed: () => !selected ? evaluateGame() : null,
              child: const Text(
                'Check',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    hintContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('CLUES:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getOptions(),
        ),
      ],
    );

    return super.build(context);
  }
}
