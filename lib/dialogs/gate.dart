import 'dart:async';

import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validators/validators.dart';

class ParentalGate extends StatefulWidget {
  const ParentalGate({Key? key}) : super(key: key);

  @override
  _ParentalGateState createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate>
    with SingleTickerProviderStateMixin {
  Timer? timer;
  int? factor;
  List? numbers;
  TabController? tabController;
  Color? btnColor = Colors.blue[900];
  List? optionSelected;

  void reload() {
    factor = DatabaseService().randomBetween(3, 6);
    optionSelected = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ];
    numbers = [];

    for (int i = 0; i < 10; i++) {
      int rand = DatabaseService().randomBetween(1, 50);
      do {
        rand = DatabaseService().randomBetween(1, 50);
      } while (isIn(rand.toString(), numbers)!);

      numbers!.add(rand);
    }

    for (int i = 0; i < 10; i++) {
      if (numbers![i] % factor == 0) {
        setState(() {});
        return;
      }
    }

    reload();
    setState(() {});
  }

  bool check() {
    for (int i = 0; i < 10; i++) {
      if (numbers![i] % factor == 0) {
        if (optionSelected![i] != true) {
          reload();
          return false;
        }
      } else {
        if (optionSelected![i] == true) {
          reload();
          return false;
        }
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    reload();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        color: Colors.blue[900],
        child: Column(
          children: [
            Container(
              height: 75,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lock,
                    size: 30,
                    color: Colors.blue[900],
                  ),
                  Text(
                    'ASK YOUR PARENTS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: MaterialButton(
                          color: btnColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.white, width: 5),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          highlightColor: Colors.orange,
                          onPressed: () {},
                          child: GestureDetector(
                            onLongPressStart: (LongPressStartDetails details) {
                              btnColor = Colors.orange;
                              timer = Timer(
                                  const Duration(seconds: 4, milliseconds: 500),
                                  () {
                                tabController!.animateTo(1);
                              });
                              setState(() {});
                            },
                            onLongPressEnd: (LongPressEndDetails details) {
                              btnColor = Colors.blue[900];
                              timer?.cancel();
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                FaIcon(FontAwesomeIcons.handPointUp, size: 50),
                                Text(
                                  'Hold for\n5 seconds',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Select the number(s) divisible by $factor',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int i = 0; i < 5; i++)
                              ButtonTheme(
                                minWidth: 45,
                                height: 45,
                                child: MaterialButton(
                                  padding: EdgeInsets.zero,
                                  color: optionSelected![i]
                                      ? Colors.green
                                      : Colors.blue[900],
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  onPressed: () {
                                    if (optionSelected![i] == true) {
                                      optionSelected![i] = false;
                                      setState(() {});
                                    } else {
                                      optionSelected![i] = true;
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    numbers![i].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int i = 5; i < 10; i++)
                              ButtonTheme(
                                minWidth: 45,
                                height: 45,
                                child: MaterialButton(
                                  padding: EdgeInsets.zero,
                                  color: optionSelected![i]
                                      ? Colors.green
                                      : Colors.blue[900],
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  onPressed: () {
                                    if (optionSelected![i] == true) {
                                      optionSelected![i] = false;
                                      setState(() {});
                                    } else {
                                      optionSelected![i] = true;
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    numbers![i].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                            ),
                            onPressed: () {
                              if (check()) Navigator.pop(context, true);
                            },
                            child: const Text(
                              'CHECK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
