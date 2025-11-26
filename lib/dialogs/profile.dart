import 'dart:io';

import 'package:biblechamps/dialogs/gate.dart';
import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  List countries = [];
  List states = [];
  Map countryCodes = {};
  int? selectedAvatar;
  bool usernameHasError = false;
  String? emailError;
  String? usernameError;
  String? newPasswordError;
  String? reAuthenticate;
  FocusNode firstnameFocusNode = FocusNode();
  FocusNode lastnameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode oldPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmNewPasswordFocusNode = FocusNode();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmNewPassword = TextEditingController();
  TextEditingController currentPassword = TextEditingController();
  TabController? tabController;
  String? country;
  String? state;
  String? token;

  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changeEmailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _deleteAccountFormKey = GlobalKey<FormState>();

  List tokenKeys = [
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
        .then((Response response) => token = response.data['auth_token']);

    await Dio()
        .get(
      'https://www.universal-tutorial.com/api/countries/',
      options: Options(
        headers: {
          'authorization': 'Bearer $token',
        },
      ),
    )
        .then((Response response) {
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
        .then((Response response) {
      setState(() {
        states = response.data.map((value) => value['state_name']).toList();
      });
    });
  }

  Future setUsername() async {
    await DatabaseService().syncUserData({
      'username': trim(username.text),
    }).then((Response response) {
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

  @override
  void initState() {
    super.initState();
    getCountries();
    tabController = TabController(length: 8, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    title: const Text('Change Avatar'),
                    subtitle: const Text('Use another avatar'),
                    leading: Image.file(
                      File(
                          '${DatabaseService().downloadPath}/images/avatar-${DatabaseService().avatar}.png'),
                      height: 37.5,
                    ),
                    onTap: () {
                      selectedAvatar = DatabaseService().avatar!;
                      setState(() {});
                      tabController!.animateTo(1);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Edit Name'),
                    subtitle: Text(
                        '${DatabaseService().firstname} ${DatabaseService().lastname}'),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.userEdit),
                    ),
                    onTap: () {
                      _nameFormKey.currentState?.reset();
                      firstname.text = DatabaseService().firstname!;
                      lastname.text = DatabaseService().lastname!;
                      setState(() {});
                      tabController!.animateTo(2);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Username'),
                    subtitle: Text(DatabaseService().username!),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.userCog),
                    ),
                    onTap: () {
                      _usernameFormKey.currentState?.reset();
                      username.text = DatabaseService().username!;
                      setState(() {});
                      tabController!.animateTo(3);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Email'),
                    subtitle: Text(AuthService().currentUser!.email!),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(IconDataSolid(0xf0e0)),
                    ),
                    onTap: () {
                      _changeEmailFormKey.currentState?.reset();
                      tabController!.animateTo(4);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Password'),
                    subtitle: const Text('Set new password'),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.lock),
                    ),
                    onTap: () {
                      _changePasswordFormKey.currentState?.reset();
                      tabController!.animateTo(5);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Change Location'),
                    subtitle: Text(
                        '${DatabaseService().state}, ${DatabaseService().country}'),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.globe),
                    ),
                    onTap: () {
                      _locationFormKey.currentState?.reset();
                      country = DatabaseService().country;
                      setState(() {});
                      getStates();
                      tabController!.animateTo(6);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Log Out'),
                    subtitle: const Text('Log out current user'),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.signOutAlt),
                    ),
                    onTap: () {
                      AuthService().logOut(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Delete Account'),
                    subtitle: const Text('Clear all my records and data'),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 7.5),
                      child: FaIcon(FontAwesomeIcons.userSlash),
                    ),
                    onTap: () async {
                      bool isGranted = await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => const ParentalGate(),
                      );

                      if (isGranted == true) {
                        _deleteAccountFormKey.currentState?.reset();
                        tabController!.animateTo(7);
                      }
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
                          color: Colors.red,
                          onPressed: () {
                            tabController!.animateTo(0);
                            setState(() {});
                          },
                        ),
                        const Text(
                          'Change Avatar',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () {
                            DatabaseService().syncUserData({
                              'avatar': selectedAvatar,
                            }).then((Response response) {
                              if (response.data['status'] == 'success') {
                                DatabaseService().setAvatar(selectedAvatar!);
                                Fluttertoast.showToast(
                                    msg: 'Avatar modification successful');
                                setState(() {});
                                tabController!.animateTo(0);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: List.generate(15, (int index) {
                          return ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(
                                      '${DatabaseService().downloadPath}/images/avatar-$index.png')),
                                  fit: BoxFit.scaleDown,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedAvatar == index
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(0.0),
                                ),
                                onPressed: () {
                                  selectedAvatar = index;
                                  setState(() {});
                                },
                                child: const SizedBox(),
                              ),
                            ),
                          );
                        }),
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
                          'Edit Name',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () {
                            if (_nameFormKey.currentState!.validate()) {
                              _nameFormKey.currentState!.save();
                              _nameFormKey.currentState!.reset();
                            }
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _nameFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: firstname,
                            focusNode: firstnameFocusNode,
                            validator: (String? value) {
                              value = trim(firstname.text);
                              if (value == '') return 'Cannot be empty';
                              return null;
                            },
                            onSaved: (String? value) {},
                            onFieldSubmitted: (String value) {
                              firstnameFocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(lastnameFocusNode);
                            },
                            maxLength: 20,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'First name',
                              counterText: '',
                            ),
                          ),
                          TextFormField(
                            controller: lastname,
                            focusNode: lastnameFocusNode,
                            validator: (String? value) {
                              value = trim(lastname.text);
                              if (value == '') return 'Cannot be empty';
                              return null;
                            },
                            onSaved: (String? value) async {
                              await DatabaseService().syncUserData({
                                'firstname': trim(firstname.text),
                                'lastname': trim(lastname.text),
                              }).then((Response response) async {
                                if (response.data['status'] == 'success') {
                                  await DatabaseService()
                                      .setFirstname(trim(firstname.text));
                                  await DatabaseService()
                                      .setLastname(trim(lastname.text));
                                  Fluttertoast.showToast(
                                      msg: 'Name modification successful');
                                  setState(() {});
                                  tabController!.animateTo(0);
                                }
                              });
                            },
                            onFieldSubmitted: (String value) {
                              if (_nameFormKey.currentState!.validate()) {
                                _nameFormKey.currentState!.save();
                                _nameFormKey.currentState!.reset();
                              }
                            },
                            maxLength: 20,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Last name',
                              counterText: '',
                            ),
                          ),
                        ],
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
                          'Change Username',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () async {
                            await setUsername();
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _usernameFormKey,
                      child: TextFormField(
                        controller: username,
                        validator: (String? value) {
                          value = trim(username.text);
                          if (isNull(value)) return 'Cannot be empty';
                          if (DatabaseService().username == value) {
                            return 'Enter another username';
                          }
                          if (!isAlphanumeric(value)) {
                            return 'Only letters and numbers allowed';
                          }
                          if (!isNull(usernameError)) return usernameError;
                          if (usernameHasError) {
                            return 'Something went wrong';
                          }
                          return null;
                        },
                        onSaved: (String? value) async {
                          value = trim(username.text);

                          await DatabaseService().setUsername(value);

                          Fluttertoast.showToast(
                              msg: 'Username modification successful');

                          setState(() {});
                          tabController!.animateTo(0);
                        },
                        onFieldSubmitted: (String value) async {
                          await setUsername();
                        },
                        maxLength: 20,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          counterText: '',
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
                          'Change Email',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () async {
                            reAuthenticate = await AuthService().reAuthenticate(
                                AuthService().currentUser!.email,
                                password.text);
                            if (reAuthenticate == null) {
                              emailError =
                                  await AuthService().updateEmail(email.text);
                              if (emailError == null) {
                                await AuthService().signOut();
                                await AuthService()
                                    .reAuthenticate(email.text, password.text);
                              }
                            }

                            if (_changeEmailFormKey.currentState!.validate()) {
                              email.clear();
                              password.clear();
                              _changeEmailFormKey.currentState!.save();
                            }
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _changeEmailFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: email,
                            focusNode: emailFocusNode,
                            validator: (String? value) {
                              value = trim(email.text);
                              if (value == '') return 'Cannot be empty';
                              if (!isEmail(value)) return 'Email not valid';
                              if (AuthService().currentUser!.email == value) {
                                return 'Enter another email';
                              }
                              if (reAuthenticate != null) return null;
                              if (emailError != null) return emailError;
                              return null;
                            },
                            onFieldSubmitted: (String value) {
                              emailFocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(passwordFocusNode);
                            },
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'New Email',
                            ),
                          ),
                          TextFormField(
                            controller: password,
                            focusNode: passwordFocusNode,
                            validator: (String? value) {
                              value = trim(password.text);
                              if (value == '') return 'Cannot be empty';
                              if (AuthService().currentUser!.email ==
                                  email.text) return null;
                              if (reAuthenticate != null) {
                                return reAuthenticate;
                              }
                              return null;
                            },
                            onSaved: (String? value) async {
                              DatabaseService().syncUserData({
                                'email': email.text,
                              });
                              setState(() {});
                              tabController!.animateTo(0);
                              Fluttertoast.showToast(
                                  msg: 'Email modification successful');
                            },
                            onFieldSubmitted: (String value) async {
                              value = trim(password.text);
                              reAuthenticate = await AuthService()
                                  .reAuthenticate(
                                      AuthService().currentUser!.email, value);
                              if (reAuthenticate == null) {
                                emailError =
                                    await AuthService().updateEmail(email.text);
                                if (emailError == null) {
                                  await AuthService().signOut();
                                  await AuthService()
                                      .reAuthenticate(email.text, value);
                                }
                              }

                              if (_changeEmailFormKey.currentState!
                                  .validate()) {
                                email.clear();
                                password.clear();
                                _changeEmailFormKey.currentState!.save();
                              }
                            },
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                        ],
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
                          'Change Password',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () async {
                            reAuthenticate = await AuthService().reAuthenticate(
                                AuthService().currentUser!.email,
                                oldPassword.text);
                            if (reAuthenticate == null) {
                              newPasswordError = await AuthService()
                                  .updatePassword(newPassword.text);
                            }

                            if (_changePasswordFormKey.currentState!
                                .validate()) {
                              newPassword.clear();
                              oldPassword.clear();
                              confirmNewPassword.clear();
                              _changePasswordFormKey.currentState!.save();
                            }
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _changePasswordFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: oldPassword,
                            focusNode: oldPasswordFocusNode,
                            validator: (String? value) {
                              value = trim(oldPassword.text);
                              if (value == '') return 'Cannot be empty';
                              if (reAuthenticate != null) {
                                return reAuthenticate;
                              }
                              return null;
                            },
                            onFieldSubmitted: (String value) {
                              oldPasswordFocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(newPasswordFocusNode);
                            },
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          TextFormField(
                            controller: newPassword,
                            focusNode: newPasswordFocusNode,
                            validator: (String? value) {
                              value = trim(newPassword.text);
                              if (value == '') return 'Cannot be empty';
                              if (reAuthenticate != null) return null;
                              if (oldPassword.text == value) {
                                return 'Enter another password';
                              }
                              if (newPasswordError != null) {
                                return newPasswordError;
                              }
                              return null;
                            },
                            onFieldSubmitted: (String value) async {
                              newPasswordFocusNode.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(confirmNewPasswordFocusNode);
                            },
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'New Passowrd',
                            ),
                          ),
                          TextFormField(
                            controller: confirmNewPassword,
                            focusNode: confirmNewPasswordFocusNode,
                            validator: (String? value) {
                              value = trim(confirmNewPassword.text);
                              if (value == '') return 'Cannot be empty';
                              if (newPasswordError != null) return null;
                              if (newPassword.text != value) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onSaved: (String? value) {
                              tabController!.animateTo(0);
                              Fluttertoast.showToast(
                                  msg: 'Password modification successful');
                            },
                            onFieldSubmitted: (String value) async {
                              reAuthenticate = await AuthService()
                                  .reAuthenticate(
                                      AuthService().currentUser!.email,
                                      oldPassword.text);
                              if (reAuthenticate == null) {
                                newPasswordError = await AuthService()
                                    .updatePassword(newPassword.text);
                              }

                              if (_changePasswordFormKey.currentState!
                                  .validate()) {
                                newPassword.clear();
                                oldPassword.clear();
                                confirmNewPassword.clear();
                                _changePasswordFormKey.currentState!.save();
                              }
                            },
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Confirm New Passowrd',
                            ),
                          ),
                        ],
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
                          'Change Location',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () {
                            if (_locationFormKey.currentState!.validate()) {
                              _locationFormKey.currentState!.save();
                              _locationFormKey.currentState!.reset();
                            }
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _locationFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButtonFormField<String>(
                            value: country,
                            items: countries.map((value) {
                              return DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              );
                            }).toList(),
                            validator: (String? value) {
                              if (country == null) return 'Cannot be empty';
                              return null;
                            },
                            onChanged: (String? value) {
                              setState(() {
                                state = null;
                                states = [];
                                country = value;
                              });
                              getStates();
                            },
                            onSaved: (String? value) {},
                            decoration: const InputDecoration(
                              labelText: 'Country',
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: state,
                            items: states.map((value) {
                              return DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              );
                            }).toList(),
                            validator: (String? value) {
                              if (state == null) return 'Cannot be empty';
                              return null;
                            },
                            onChanged: (String? value) {
                              setState(() => state = value);
                            },
                            onSaved: (String? value) async {
                              await DatabaseService().syncUserData({
                                'country': country,
                                'countrycode': countryCodes[country],
                                'state': state,
                              }).then((Response response) async {
                                if (response.data['status'] == 'success') {
                                  await DatabaseService().setCountry(country!);
                                  await DatabaseService()
                                      .setCountrycode(countryCodes[country]);
                                  await DatabaseService().setState(state!);
                                  Fluttertoast.showToast(
                                      msg: 'Location modification successful');
                                  setState(() {});
                                  tabController!.animateTo(0);
                                }
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                          ),
                        ],
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
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.check),
                          tooltip: 'Submit',
                          color: Colors.green,
                          onPressed: () async {
                            reAuthenticate = await AuthService().reAuthenticate(
                                AuthService().currentUser!.email,
                                currentPassword.text);

                            if (_deleteAccountFormKey.currentState!
                                .validate()) {
                              _deleteAccountFormKey.currentState!.save();
                              _deleteAccountFormKey.currentState!.reset();
                            }
                          },
                        ),
                      ],
                    ),
                    Form(
                      key: _deleteAccountFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This would clear all your data on our servers, and delete your account from our database. All records would be destroyed.',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Please proceed with caution, this process cannot be reversed!',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Enter your password to proceed!',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          TextFormField(
                            controller: currentPassword,
                            validator: (String? value) {
                              value = trim(currentPassword.text);
                              if (value == '') return 'Cannot be empty';
                              if (reAuthenticate != null) {
                                return reAuthenticate;
                              }
                              return null;
                            },
                            onSaved: (String? value) async {
                              String idToken =
                                  await AuthService().currentUser!.getIdToken();

                              await Dio()
                                  .delete(
                                '${DatabaseService().apiUrl}/user',
                                options: Options(
                                  headers: {
                                    'authorization': 'Bearer $idToken',
                                  },
                                ),
                              )
                                  .then((Response response) {
                                if (response.data['status'] == 'success') {
                                  AuthService().logOut(context);
                                }
                              });
                            },
                            onFieldSubmitted: (String value) async {
                              reAuthenticate = await AuthService()
                                  .reAuthenticate(
                                      AuthService().currentUser!.email,
                                      currentPassword.text);

                              if (_deleteAccountFormKey.currentState!
                                  .validate()) {
                                _deleteAccountFormKey.currentState!.save();
                                _deleteAccountFormKey.currentState!.reset();
                              }
                            },
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    oldPassword.dispose();
    newPassword.dispose();
    confirmNewPassword.dispose();
    currentPassword.dispose();
    tabController?.dispose();
    super.dispose();
  }
}
