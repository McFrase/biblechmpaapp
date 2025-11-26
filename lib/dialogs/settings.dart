import 'dart:io';

import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List expansionTrack = List.filled(DatabaseService().faqs!.length, false);
  bool contactUsHasError = false;

  final FocusNode subjectFocusNode = FocusNode();
  final FocusNode messageFocusNode = FocusNode();
  final TextEditingController subject = TextEditingController();
  final TextEditingController message = TextEditingController();
  final GlobalKey<FormState> _contactUsFormKey = GlobalKey<FormState>();

  Future contactUs() async {
    String idToken = await AuthService().currentUser!.getIdToken();

    await Dio().post(
      '${DatabaseService().apiUrl}/messages/add',
      options: Options(
        headers: {
          'authorization': 'Bearer $idToken',
        },
      ),
      data: {
        'subject': trim(subject.text),
        'message': trim(message.text),
      },
    ).then((Response response) {
      if (response.data['status'] == 'success') {
        contactUsHasError = false;
      } else {
        contactUsHasError = true;
      }
    });

    if (_contactUsFormKey.currentState!.validate()) {
      _contactUsFormKey.currentState!.save();
      _contactUsFormKey.currentState!.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: 400,
        child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 25, 0, 0),
                  child: Text(
                    'UPDATES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Application Update'),
                  subtitle: DatabaseService().hasAndroidUpdate()
                      ? Text(
                          'A new version of Bible Champs (v${DatabaseService().androidVersionUpdate}) is available! Stay up to date with latest features, upgrades, games, and more!! Update now!!!')
                      : const Text(
                          'Unavailable, you have the latest Bible Champs installed'),
                  leading: const FaIcon(FontAwesomeIcons.syncAlt),
                  enabled: DatabaseService().hasAndroidUpdate(),
                  onTap: () async {
                    String url = DatabaseService().dynamicUrl!;

                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                ListTile(
                  title: const Text('Update Application Data'),
                  subtitle: Text(
                      'Last Updated ${DateFormat.yMMMMd().format(DateTime.fromMillisecondsSinceEpoch(DatabaseService().lastValidated).toUtc())}'),
                  leading: const FaIcon(FontAwesomeIcons.redoAlt),
                  onTap: () => UiService().showAlert(
                    context,
                    title: 'Update Application Data',
                    desc:
                        'This will download and install the latest application data. You will not be able to use the application until the process is complete. Proceed?',
                    isWarning: true,
                    hasCancelButton: true,
                    cancelButtonText: 'NO',
                    buttonText: 'YES',
                    onClick: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/downloadfiles', (Route route) => false);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 25, 0, 0),
                  child: Text(
                    'SOUND',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('Volume'),
                  ),
                  subtitle: Slider(
                    value: AudioService().appVolume,
                    label: '${(AudioService().appVolume * 100).round()}',
                    onChanged: (double value) {
                      setState(() => AudioService().appVolume = value);
                    },
                  ),
                  leading: const FaIcon(FontAwesomeIcons.volumeUp),
                ),
                const Divider(),
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('Music'),
                  ),
                  subtitle: Slider(
                    value: AudioService().musicVolume,
                    onChanged: AudioService().appVolume > 0
                        ? (double value) {
                            setState(() => AudioService().musicVolume = value);
                          }
                        : null,
                  ),
                  enabled: AudioService().appVolume > 0 ? true : false,
                  leading: const FaIcon(FontAwesomeIcons.music),
                ),
                const Divider(),
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('Voice'),
                  ),
                  subtitle: Slider(
                    value: AudioService().voiceVolume,
                    onChanged: AudioService().appVolume > 0
                        ? (double value) {
                            setState(() => AudioService().voiceVolume = value);
                          }
                        : null,
                  ),
                  enabled: AudioService().appVolume > 0 ? true : false,
                  leading: const Icon(Icons.record_voice_over, size: 30),
                ),
                const Divider(),
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('SFX'),
                  ),
                  subtitle: Slider(
                    value: AudioService().sfxVolume,
                    onChanged: AudioService().appVolume > 0
                        ? (double value) {
                            setState(() => AudioService().sfxVolume = value);
                          }
                        : null,
                  ),
                  enabled: AudioService().appVolume > 0 ? true : false,
                  leading: const FaIcon(FontAwesomeIcons.drum),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 25, 0, 0),
                  child: Text(
                    'HELP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('FAQ'),
                  subtitle: const Text('Frequently asked questions'),
                  leading: const FaIcon(IconDataSolid(0xf059)),
                  onTap: () {
                    tabController!.animateTo(2);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Contact Us'),
                  subtitle: const Text(
                      'Questions, need help, request feature, report issues, e.t.c.'),
                  leading: const FaIcon(FontAwesomeIcons.users),
                  onTap: () {
                    tabController!.animateTo(3);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read latest privacy policy'),
                  leading: const FaIcon(FontAwesomeIcons.filePdf),
                  onTap: () async {
                    String filePath =
                        '${DatabaseService().downloadPath}/privacy-policy.pdf';

                    try {
                      await Dio().download(
                        DatabaseService().policyUrl!,
                        filePath,
                      );

                      OpenFile.open(filePath);
                    } on DioError catch (e) {
                      Fluttertoast.showToast(msg: e.message);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Share'),
                  subtitle: const Text('Share Bible Champs with friends'),
                  leading: const FaIcon(FontAwesomeIcons.shareAlt),
                  onTap: () {
                    Share.share(
                      "Download the Bible Champs application now. Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child. \n${DatabaseService().dynamicUrl}",
                      subject: 'Bible Champs',
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('Application info'),
                  leading: const FaIcon(FontAwesomeIcons.infoCircle),
                  onTap: () {
                    tabController!.animateTo(1);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                        tooltip: 'Back',
                        onPressed: () {
                          tabController!.animateTo(0);
                        },
                      ),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset(
                            'assets/icon/icon.png',
                            height: 75,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Bible Champs',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.blue[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'v${DatabaseService().androidVersion}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "Bible Champs is an interactive, gamified learning children's application for all ages, with Games, Videos, Music and More. It's engaging and a must have for every child.",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "(c)2020 LoveWorld Children's Ministry. All Rights Reserved.",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Image.file(
                            File(
                                '${DatabaseService().downloadPath}/images/lwcm-banner.png'),
                            height: 30,
                          ),
                          const SizedBox(height: 25),
                          const Text.rich(
                            TextSpan(
                              text: 'Powered by Rockect Solutions\n',
                              children: [
                                TextSpan(
                                  text: 'www.rockect.com',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                        tooltip: 'Back',
                        onPressed: () {
                          tabController!.animateTo(0);
                        },
                      ),
                      const Text(
                        'FAQs',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ExpansionPanelList(
                        expandedHeaderPadding: EdgeInsets.zero,
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            expansionTrack[index] = !isExpanded;
                          });
                        },
                        children: DatabaseService()
                            .faqs!
                            .asMap()
                            .entries
                            .map<ExpansionPanel>(
                                (MapEntry<int, dynamic> entry) {
                          return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                  title: Text(entry.value['question']),
                                  onTap: () {
                                    setState(() {
                                      expansionTrack[entry.key] = !isExpanded;
                                    });
                                  });
                            },
                            body: GestureDetector(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                    left: 15,
                                    right: 15,
                                  ),
                                  child: Text(
                                    entry.value['answer'],
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    expansionTrack[entry.key] = false;
                                  });
                                }),
                            isExpanded: expansionTrack[entry.key] == true,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                        tooltip: 'Back',
                        color: Colors.red,
                        onPressed: () {
                          tabController!.animateTo(0);
                        },
                      ),
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.check),
                        tooltip: 'Submit',
                        color: Colors.green,
                        onPressed: () async {
                          await contactUs();
                        },
                      ),
                    ],
                  ),
                  Form(
                    key: _contactUsFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: subject,
                          focusNode: subjectFocusNode,
                          validator: (String? value) {
                            value = trim(subject.text);
                            if (isNull(value)) return 'Cannot be empty';
                            if (contactUsHasError) {
                              return 'Something went wrong';
                            }
                            return null;
                          },
                          onSaved: (String? value) {},
                          onFieldSubmitted: (String value) async {
                            subjectFocusNode.unfocus();
                            FocusScope.of(context)
                                .requestFocus(messageFocusNode);
                          },
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            hintText: 'Enter subject',
                            counterText: '',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          controller: message,
                          focusNode: messageFocusNode,
                          validator: (String? value) {
                            value = trim(message.text);
                            if (isNull(value)) return 'Cannot be empty';
                            if (contactUsHasError) {
                              return 'Something went wrong';
                            }
                            return null;
                          },
                          onSaved: (String? value) async {
                            Fluttertoast.showToast(
                                msg:
                                    'Thank you for contacting us. We have gotten your message and would get back to you shortly!');

                            tabController!.animateTo(0);
                          },
                          onFieldSubmitted: (String value) async {
                            await contactUs();
                          },
                          maxLength: 1000,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter message',
                            counterText: '',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
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
    message.dispose();
    tabController?.dispose();
    super.dispose();
  }
}
