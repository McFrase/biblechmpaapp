import 'dart:io';

import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage>
    with SingleTickerProviderStateMixin {
  String? country;
  String? state;
  String? token;
  String? usernameError;
  bool usernameHasError = false;
  List countries = [];
  List states = [];
  Map countryCodes = {};
  List<Widget> dots = [];
  List<double> sizeDots = [];
  List<double> opacityDots = [];
  TabController? tabController;

  // For Dot indicator
  double sizeDot = 10.0;
  double marginLeftDotFocused = 0;
  double marginRightDotFocused = 0;
  double? initValueMarginRight;

  final FocusNode firstnameFocusNode = FocusNode();
  final FocusNode lastnameFocusNode = FocusNode();
  final TextEditingController username = TextEditingController();
  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();

  final List tokenKeys = [
    {
      'email': 'basseydavid@gmail.com',
      'token':
          'kXWwcWTKI9EFeeDYxkKlknsmevuMFZDfN8PYKPd6UPXxgZ88KGMMqeGdmWOKcJPJaA0'
    },
    {
      'email': 'basseydavid1@gmail.com',
      'token':
          '9nkrXB7hHmQERHJ-XKCjrG-LQyti4AHTIre1D5wtWZEcXHrgcuKB4XrgR1HwLw2nRu0'
    },
    {
      'email': 'basseydavid2@gmail.com',
      'token':
          'oqldA3MzTPKOEGqx43N-3M9JxZQI0St8y77Y3DuNgmKeuUKmCXJhc8r0D_cQ9LuJSlA'
    },
    {
      'email': 'basseydavid3@gmail.com',
      'token':
          'vr0rL6hif3Yo3f99AeRzWcf9db8oBvqHvq8-v_Isbcpy0MnEjbvQZtKnfs5V7PlRYOk'
    },
    {
      'email': 'basseydavid4@gmail.com',
      'token':
          '6MXPVqnGSENhrUvB8r3CwZP4374JO7ywbvPwc8kLEZc1RSx6egnw6nuUsLmyHBultGg'
    },
    {
      'email': 'basseydavid5@gmail.com',
      'token':
          'YdaIE596LnqL7ELeKd0bxqhURqErn1n-zVmuNuQv7TnogMJodpdg9Rj0cchfK_Dci9U'
    },
  ];

  Future getCountries() async {
    Map tokenKey =
        tokenKeys[DatabaseService().randomBetween(0, tokenKeys.length)];

    await Dio()
        .get(
          'https://www.universal-tutorial.com/api/getaccesstoken',
          options: Options(
            headers: {
              'Accept': 'application/json',
              'api-token': tokenKey['token'],
              'user-email': tokenKey['email'],
            },
          ),
        )
        .then((response) => token = response.data['auth_token']);

    await Dio()
        .get(
      'https://www.universal-tutorial.com/api/countries/',
      options: Options(
        headers: {
          'authorization': 'Bearer $token',
        },
      ),
    )
        .then((response) {
      response.data.forEach((value) {
        countryCodes[value['country_name']] = value['country_short_name'];
      });

      setState(() {
        countries =
            response.data.map((value) => value['country_name']).toList();
      });
    });
  }

  Future getStates() async {
    await Dio()
        .get(
      'https://www.universal-tutorial.com/api/states/$country',
      options: Options(
        headers: {
          'authorization': 'Bearer $token',
        },
      ),
    )
        .then((response) {
      setState(() {
        states = response.data.map((value) => value['state_name']).toList();
      });
    });
  }

  Future setUsername() async {
    await DatabaseService().syncUserData({
      'username': trim(username.text),
    }).then((response) {
      if (response.data['status'] == 'success') {
        usernameHasError = false;
      } else {
        usernameHasError = true;
      }

      if (response.data['status'] == 'error') {
        usernameError = response.data['message'];
      } else {
        usernameError = null;
      }
    });

    if (_usernameFormKey.currentState!.validate()) {
      _usernameFormKey.currentState!.save();
      _usernameFormKey.currentState!.reset();
    }
  }

  List<Widget> renderListDots() {
    dots.clear();
    for (int i = 0; i < tabController!.length; i++) {
      dots.add(renderDot(
        sizeDots[i],
        Colors.white.withOpacity(0.3),
        opacityDots[i],
      ));
    }
    return dots;
  }

  Widget renderDot(double radius, Color color, double opacity) {
    return Opacity(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius / 2),
        ),
        width: radius,
        height: radius,
        margin: EdgeInsets.only(
          left: radius / 2,
          right: radius / 2,
        ),
      ),
      opacity: opacity,
    );
  }

  Widget renderTab({bgColor, image, child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 60.0),
      alignment: const Alignment(0.0, 0.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image,
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderBottom() {
    return Positioned(
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: const SizedBox(),
            width: MediaQuery.of(context).size.width / 4,
          ),

          // Dot indicator
          Flexible(
            child: Stack(
              children: <Widget>[
                Row(
                  children: renderListDots(),
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sizeDot / 2),
                    ),
                    width: sizeDot,
                    height: sizeDot,
                    margin: EdgeInsets.only(
                      left: marginLeftDotFocused,
                      right: marginRightDotFocused,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Next, Done button
          Container(
            alignment: Alignment.center,
            child: tabController!.index + 1 == tabController!.length
                ? buildDoneButton()
                : buildNextButton(),
            width: MediaQuery.of(context).size.width / 4,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget buildDoneButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white.withOpacity(0.3),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: () => UiService().nextPage(context),
      child: const Icon(
        Icons.done,
        color: Colors.white,
        size: 35.0,
      ),
    );
  }

  void goNext() {
    if (DatabaseService().username == '') {
      tabController!.animateTo(1);
    } else if (DatabaseService().firstname == '' ||
        DatabaseService().lastname == '') {
      tabController!.animateTo(2);
    } else if (DatabaseService().country == '' ||
        DatabaseService().state == '') {
      tabController!.animateTo(3);
    } else {
      tabController!.animateTo(4);
    }
  }

  Widget buildNextButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white.withOpacity(0.3),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: () async {
        if (tabController!.index == 1) {
          await setUsername();
        } else if (tabController!.index == 2) {
          if (_nameFormKey.currentState!.validate()) {
            _nameFormKey.currentState!.save();
          }
        } else if (tabController!.index == 3) {
          if (_locationFormKey.currentState!.validate()) {
            _locationFormKey.currentState!.save();
          }
        } else {
          goNext();
        }
      },
      child: const Icon(
        Icons.navigate_next,
        color: Colors.white,
        size: 35.0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    getCountries();

    tabController = TabController(length: 5, vsync: this);

    initValueMarginRight = (sizeDot * 2) * (tabController!.length - 1);

    for (int i = 0; i < tabController!.length; i++) {
      sizeDots.add(sizeDot);
      opacityDots.add(1.0);
    }
    marginRightDotFocused = initValueMarginRight!;

    tabController!.animation!.addListener(() {
      setState(() {
        marginLeftDotFocused = tabController!.animation!.value * sizeDot * 2;
        marginRightDotFocused = initValueMarginRight! -
            tabController!.animation!.value * sizeDot * 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          TabBarView(
            children: [
              renderTab(
                bgColor: const Color(0xff203152),
                image: Image.file(
                  File('${DatabaseService().downloadPath}/images/data1.png'),
                  width: 300,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Almost Done!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "Couple more steps and you'd be ready to roll. Please complete the forms that follow!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              renderTab(
                bgColor: Colors.cyan[900],
                image: Image.file(
                  File('${DatabaseService().downloadPath}/images/data2.png'),
                  width: 200,
                ),
                child: Form(
                  key: _usernameFormKey,
                  child: TextFormField(
                    controller: username,
                    validator: (value) {
                      value = trim('$value');
                      if (isNull(value)) return 'Cannot be empty';
                      if (!isAlphanumeric(value)) {
                        return 'Only letters and numbers allowed';
                      }
                      if (!isNull(usernameError)) return usernameError;
                      if (usernameHasError) {
                        return 'Something went wrong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      DatabaseService().setUsername(value!);
                      goNext();
                    },
                    onFieldSubmitted: (value) async {
                      await setUsername();
                    },
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                      counterText: '',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              renderTab(
                bgColor: Colors.blueGrey[900],
                image: Image.file(
                  File('${DatabaseService().downloadPath}/images/data3.png'),
                  width: 200,
                ),
                child: Form(
                  key: _nameFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        focusNode: firstnameFocusNode,
                        validator: (value) {
                          value = trim('$value');
                          if (isNull(value)) return 'Cannot be empty';
                          return null;
                        },
                        onSaved: (value) {
                          value = trim(value!);

                          DatabaseService().syncUserData({
                            'firstname': value,
                          }).then((response) {
                            if (response.data['status'] == 'success') {
                              DatabaseService().setFirstname(value!);
                            }
                          });
                        },
                        onFieldSubmitted: (value) {
                          firstnameFocusNode.unfocus();
                          FocusScope.of(context)
                              .requestFocus(lastnameFocusNode);
                        },
                        maxLength: 20,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextFormField(
                        focusNode: lastnameFocusNode,
                        validator: (value) {
                          value = trim('$value');
                          if (isNull(value)) return 'Cannot be empty';
                          return null;
                        },
                        onSaved: (value) {
                          value = trim(value!);

                          DatabaseService().syncUserData({
                            'lastname': value,
                          }).then((response) {
                            if (response.data['status'] == 'success') {
                              DatabaseService().setLastname(value!);
                              goNext();
                            }
                          });
                        },
                        onFieldSubmitted: (value) {
                          if (_nameFormKey.currentState!.validate()) {
                            _nameFormKey.currentState!.save();
                          }
                        },
                        maxLength: 20,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              renderTab(
                bgColor: Colors.lightGreen[900],
                image: Image.file(
                  File('${DatabaseService().downloadPath}/images/data4.png'),
                  width: 225,
                ),
                child: Form(
                  key: _locationFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.grey[800],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: country,
                          items: countries.map((value) {
                            return DropdownMenuItem<String>(
                              child: Text(value),
                              value: value,
                            );
                          }).toList(),
                          validator: (value) {
                            if (isNull(value)) return 'Cannot be empty';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              state = null;
                              states = [];
                              country = value;
                            });
                            getStates();
                          },
                          onSaved: (value) {},
                          iconEnabledColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.grey[800],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: state,
                          items: states.map((value) {
                            return DropdownMenuItem<String>(
                              child: Text(value),
                              value: value,
                            );
                          }).toList(),
                          validator: (value) {
                            if (isNull(value)) return 'Cannot be empty';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => state = value);
                          },
                          onSaved: (value) {
                            DatabaseService().syncUserData({
                              'country': country,
                              'countrycode': countryCodes[country],
                              'state': state,
                            }).then((response) {
                              if (response.data['status'] == 'success') {
                                DatabaseService().setCountry(country!);
                                DatabaseService()
                                    .setCountrycode(countryCodes[country]);
                                DatabaseService().setState(state!);
                                goNext();
                              }
                            });
                          },
                          iconEnabledColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              renderTab(
                bgColor: Colors.lightBlue[900],
                image: Image.file(
                  File('${DatabaseService().downloadPath}/images/data5.png'),
                  width: 300,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "That's it!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      'You have completed your registration, please proceed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
          ),
          renderBottom(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    username.dispose();
    tabController?.dispose();
    super.dispose();
  }
}
