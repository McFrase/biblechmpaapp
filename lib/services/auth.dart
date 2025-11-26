import 'package:biblechamps/services/audio.dart';
import 'package:biblechamps/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void authInit() {
    _auth.userChanges().listen((User? user) => _user = user);
  }

  User? get currentUser {
    return _user;
  }

  Future<String?> logIn(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await DatabaseService().fullLogin();
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  Future<String?> register(email, password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await DatabaseService().fullLogin();
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  Future<String?> resetPassword(email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  Future<String?> updateEmail(email) async {
    try {
      await _user!.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  Future<String?> updatePassword(password) async {
    try {
      await _user!.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  Future signOut() async {
    await _auth.signOut();
  }

  Future<String?> reAuthenticate(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    }

    return null;
  }

  void logOut(context) async {
    _auth.signOut();
    await DatabaseService().clearData();
    AudioService().destroyAudio();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/auth', (Route route) => false);
  }
}
