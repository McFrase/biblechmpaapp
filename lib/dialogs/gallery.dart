import 'dart:io';

import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  File? current;
  List? screenshots;
  TabController? tabController;

  Future prepare() async {
    screenshots =
        await Directory(DatabaseService().galleryPath).list().toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    prepare();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400.0,
        height: 275.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(
                '${DatabaseService().downloadPath}/images/bg-gallery.jpg')),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            GridView.count(
              padding: const EdgeInsets.all(25),
              crossAxisSpacing: 20,
              mainAxisSpacing: 0,
              crossAxisCount: 4,
              children: List.generate(screenshots?.length ?? 0, (int index) {
                return GestureDetector(
                  onTap: () async {
                    current = screenshots![index];
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 50));
                    tabController!.animateTo(1);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.5),
                        child: Image.file(screenshots![index], width: 100),
                      ),
                      Image.file(File(
                          '${DatabaseService().downloadPath}/images/frame.png')),
                    ],
                  ),
                );
              }),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
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
                              tabController!.animateTo(0);
                            },
                            child: const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7.5, right: 7.5),
                          child: ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(
                                      '${DatabaseService().downloadPath}/images/button-share.png')),
                                ),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(0.0),
                                ),
                                onPressed: () {
                                  Share.shareFiles(
                                    [current!.path],
                                    mimeTypes: ['image/png'],
                                    subject: 'Bible Champs',
                                    text:
                                        "I did this with Bible Champs. Download the Bible Champs application now. Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child. \n${DatabaseService().dynamicUrl}",
                                  );
                                },
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7.5, right: 7.5),
                          child: ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(
                                      '${DatabaseService().downloadPath}/images/button-trash.png')),
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
                                        'This process is irreversible. Proceed to delete?',
                                    isWarning: true,
                                    hasCancelButton: true,
                                    cancelButtonText: 'NO',
                                    cancelButtonColor: Colors.orange,
                                    buttonText: 'YES',
                                    buttonColor: Colors.red,
                                    onClick: () async {
                                      await current!.delete();
                                      await prepare();
                                      await Future.delayed(
                                          const Duration(milliseconds: 50));
                                      tabController!.animateTo(0);
                                    },
                                  );
                                },
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: (current != null)
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              current!,
                              width: 225,
                            ),
                            Image.file(
                              File(
                                  '${DatabaseService().downloadPath}/images/frame.png'),
                              width: 290,
                              height: 300,
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
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
