import 'dart:io';
import 'dart:typed_data';

import 'package:biblechamps/dialogs/editor.dart';
import 'package:biblechamps/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Celebrations extends StatefulWidget {
  const Celebrations({Key? key}) : super(key: key);

  @override
  _CelebrationsState createState() => _CelebrationsState();
}

class _CelebrationsState extends State<Celebrations> {
  XFile? pickedFile;
  List celebrations = [];
  ImagePicker picker = ImagePicker();

  void showEditor(type) async {
    pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (Platform.isAndroid) {
      LostDataResponse response = await picker.retrieveLostData();
      if (!response.isEmpty && response.file != null) {
        pickedFile = response.file;
      }
    }

    Uint8List? bytes = await pickedFile!.readAsBytes();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Editor(type, bytes),
    );
  }

  @override
  void initState() {
    super.initState();

    celebrations = DatabaseService()
        .celebrationSettings!
        .where((value) => value['status'] == 1)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: 400,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: celebrations.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(DatabaseService()
                  .celebrationBounds[celebrations[index]['name']]['title']),
              subtitle:
                  const Text('Share and celebrate with friends and family'),
              leading: FaIcon(DatabaseService()
                  .celebrationBounds[celebrations[index]['name']]['icon']),
              onTap: () => showEditor(celebrations[index]['name']),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }
}
