import 'dart:io';

import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';

class MemoryVerses extends StatefulWidget {
  const MemoryVerses({Key? key}) : super(key: key);

  @override
  _MemoryVersesState createState() => _MemoryVersesState();
}

class _MemoryVersesState extends State<MemoryVerses>
    with SingleTickerProviderStateMixin {
  String mode = DatabaseService().memoryVerseType ?? 'preschool';
  List preschoolVerses = DatabaseService().preschoolMemoryVerses!;
  List preteensVerses = DatabaseService().preteensMemoryVerses!;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: preschoolVerses.length,
      initialIndex: DatabaseService().memoryVerseIndex ?? 0,
    );

    _tabController!.addListener(() =>
        DatabaseService().memoryVerseMemorize(mode, _tabController!.index));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.00,
          height: 252.16,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(
                  '${DatabaseService().downloadPath}/images/bg-memoryverses-$mode.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: mode == 'preschool' ? 65 : 50,
                    height: mode == 'preschool' ? 56.55 : 50,
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(
                            "${DatabaseService().downloadPath}/images/icon-${mode == 'preschool' ? 'preteens' : 'preschool'}.png")),
                      ),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0.0),
                      ),
                      onPressed: () {
                        mode == 'preschool'
                            ? mode = 'preteens'
                            : mode = 'preschool';
                        DatabaseService()
                            .memoryVerseMemorize(mode, _tabController!.index);
                        setState(() {});
                      },
                      child: const SizedBox(),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: mode == 'preschool'
                    ? TabBarView(
                        controller: _tabController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: preschoolVerses.map((value) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              mode == 'preschool'
                                  ? Text.rich(
                                      TextSpan(
                                        text: value['verse']
                                            .trim()
                                            .substring(
                                                0,
                                                (value['verse']
                                                            .trim()
                                                            .substring(0, 2)
                                                            .toUpperCase() ==
                                                        'EX')
                                                    ? 2
                                                    : 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: value['verse']
                                                .trim()
                                                .substring((value['verse']
                                                            .trim()
                                                            .substring(0, 2)
                                                            .toUpperCase() ==
                                                        'EX')
                                                    ? 2
                                                    : 1),
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center)
                                  : Text(
                                      value['verse'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                              Text(
                                value['scripture'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : DefaultTabController(
                        length: preteensVerses.length,
                        child: TabBarView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: preteensVerses.map((value) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  value['verse'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  value['scripture'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
              const Text(
                'SWIPE TO SEE MORE',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    AudioService().normalizeMusic();
    super.dispose();
  }
}
