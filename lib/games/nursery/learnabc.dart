import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:biblechamps/classes/game.dart';
import 'package:biblechamps/dialogs/alphabet.dart';
import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class NurseryLearnAbcGame extends StatefulWidget {
  const NurseryLearnAbcGame({Key? key}) : super(key: key);

  @override
  NurseryLearnAbcGameState createState() => NurseryLearnAbcGameState();
}

class NurseryLearnAbcGameState extends GameState<NurseryLearnAbcGame> {
  NurseryLearnAbcGameState() : super('nursery', 'learnabc');

  Map script = {
    'a': {
      'highlight': 'A IS FOR ANGEL',
      'description': 'ANGELS ARE MESSENGERS OF GOD.'
    },
    'b': {
      'highlight': 'B IS FOR BIBLE',
      'description': 'THE BIBLE IS THE BOOK THAT CONTAINS GOD’S WORD.'
    },
    'c': {
      'highlight': 'C IS FOR THE CROSS',
      'description': 'JESUS DIED ON THE CROSS AT CALVARY.'
    },
    'd': {
      'highlight': 'D IS FOR DANIEL',
      'description': 'DANIEL WAS A JEW; HE SERVED GOD WITH HIS WHOLE HEART.'
    },
    'e': {
      'highlight': 'E IS FOR ENOCH',
      'description': 'ENOCH WALKED CLOSELY WITH GOD.'
    },
    'f': {
      'highlight': 'F IS FOR FAITH',
      'description': 'FAITH IS COMPLETE TRUST IN GOD.'
    },
    'g': {
      'highlight': 'G IS FOR GENESIS',
      'description':
          'GENESIS MEANS BEGINNING. GOD MADE THE WHOLE WORLD IN THE BEGINNING.'
    },
    'h': {
      'highlight': 'H IS FOR HEAVEN',
      'description': 'HEAVEN IS WHERE GOD’S THRONE IS.'
    },
    'i': {
      'highlight': 'I IS FOR ISREALITIES',
      'description': 'THEY ARE THE CHILDREN OF FATHER ABRAHAM.'
    },
    'j': {
      'highlight': 'J IS FOR JESUS',
      'description': 'JESUS IS THE SON OF GOD.'
    },
    'k': {
      'highlight': 'K IS FOR KINGDOM',
      'description': 'WE ARE IN THE KINGDOM OF GOD.'
    },
    'l': {'highlight': 'L IS LOVE', 'description': 'GOD IS LOVE.'},
    'm': {
      'highlight': 'M IS FOR MOSES',
      'description': 'MOSES LED THE CHILDREN OF ISREAL OUT OF EGYPT.'
    },
    'n': {
      'highlight': 'N IS NOAH',
      'description': 'NOAH BUILT THE ARK OF GOD.'
    },
    'o': {
      'highlight': 'O IS FOR OBEY',
      'description':
          'TO OBEY IS TO DO WHAT YOU ARE TOLD TO DO AT THE RIGHT TIME.'
    },
    'p': {
      'highlight': 'P IS FOR PETER',
      'description': 'PETER WAS A DISCIPLE OF JESUS.'
    },
    'q': {
      'highlight': 'Q IS FOR QUEEN ESTHER',
      'description': 'QUEEN ESTHER SAVED THE ISREALITIES.'
    },
    'r': {
      'highlight': 'R IS REIGN',
      'description': 'I REIGN IN LIFE AS A KING.'
    },
    's': {
      'highlight': 'S IS FOR SOLOMON',
      'description':
          'SOLOMON IS THE WISEST MAN THAT EVER LIVED BEFORE JESUS WAS BORN.'
    },
    't': {
      'highlight': 'T IS FOR TIMOTHY',
      'description':
          'TIMOTHY BECAME THE PASTOR OF THE EPHESIAN CHURCH AS A VERY YOUNG MAN.'
    },
    'u': {
      'highlight': 'U IS FOR UNIQUE',
      'description': 'TO BE UNIQUE IS TO STAND OUT.'
    },
    'v': {
      'highlight': 'V IS FOR VICTOR',
      'description': 'A VICTOR IS ONE WHO WINS ALWAYS.'
    },
    'w': {
      'highlight': 'W IS FOR WORSHIP',
      'description': 'WORSHIP IS TO SAY BEAUTIFUL AND LOVELY THINGS TO GOD.'
    },
    'x': {
      'highlight': 'X IS FOR XERXES',
      'description':
          'XERXES WAS A GREAT KING AND HIS KINGDOM WAS VERY LARGE. HE MARRIED QUEEN ESTHER.'
    },
    'y': {
      'highlight': 'Y IS FOR YOU',
      'description': 'YOU ARE THE LIGHT OF THE WORLD.'
    },
    'z': {
      'highlight': 'Z IS FOR ZEAL',
      'description': 'ZEAL MEANS A GREAT WILL TO DO SOMETHING.'
    }
  };

  @override
  Widget nextGame() {
    return const NurseryLearnAbcGame();
  }

  @override
  void initState() {
    super.initState();

    background = 'bg-11.jpg';
  }

  @override
  Widget build(BuildContext context) {
    gameWidget = SizedBox(
      height: double.maxFinite,
      child: GridView.count(
        padding: const EdgeInsets.all(25),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 9,
        children: List.generate(26, (index) {
          String char = String.fromCharCodes(['a'.codeUnitAt(0) + index]);

          return ElasticIn(
            delay: Duration(milliseconds: 100 * (index + 1)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(5.0),
              ),
              onPressed: () async {
                AudioService().sayAlphabetInfo(char);
                await showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => Alphabet(char, script[char]),
                );

                AudioService().normalizeMusic();
              },
              child: Image.file(File(
                  '${DatabaseService().downloadPath}/images/letter-$char.png')),
            ),
          );
        }),
      ),
    );

    return super.build(context);
  }
}
