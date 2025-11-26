import 'dart:io';

import 'package:achievement_view/achievement_view.dart';
import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/download.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UiService {
  void showAchievement(
    BuildContext context, {
    required String title,
    required String subTitle,
    required IconData icon,
  }) {
    AchievementView(
      context,
      title: title,
      subTitle: subTitle,
      duration: const Duration(seconds: 1),
      icon: Center(
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 25,
        ),
      ),
      isCircle: true,
    ).show();
  }

  void nextPage(BuildContext context) async {
    if (!await DatabaseService().checkPermission()) return;

    if (!await DownloadService().isAssetsDownloaded()) {
      Navigator.of(context).pushReplacementNamed('/downloadfiles');
    } else if (AuthService().currentUser == null ||
        !DatabaseService().fullyLoggedIn) {
      AuthService().logOut(context);
    } else if (DatabaseService().isNewUser()) {
      Navigator.of(context).pushReplacementNamed('/data');
    } else {
      await DownloadService().loadData();
      await DatabaseService().depleteMultiplier();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Alert? closeAlert(Alert? alert) {
    alert?.dismiss();
    return null;
  }

  AlertType? getAlertType(
      bool isSuccess, bool isInfo, bool isWarning, bool isError) {
    if (isError) return AlertType.error;
    if (isWarning) return AlertType.warning;
    if (isInfo) return AlertType.info;
    if (isSuccess) return AlertType.success;

    return null;
  }

  void showAlert(
    BuildContext context, {
    bool canDismiss = true,
    bool isSuccess = false,
    bool isInfo = false,
    bool isWarning = false,
    bool isError = false,
    bool hasCancelButton = false,
    bool buttonWillPop = false,
    bool buttonWillClick = true,
    Widget? content,
    String? title,
    String? desc,
    String? imagePath,
    String? buttonText,
    String? cancelButtonText,
    Color? buttonColor,
    Color? cancelButtonColor,
    Function? onPop,
    Function? onClick,
  }) async {
    Alert? alert;

    alert = Alert(
      context: context,
      title: title,
      desc: desc,
      type: getAlertType(isSuccess, isInfo, isWarning, isError),
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationType: AnimationType.grow,
        animationDuration: Duration(milliseconds: 500),
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      image: imagePath != null
          ? Image.file(
              File(imagePath),
              height: 175,
            )
          : null,
      content: content ?? const SizedBox(),
      buttons: [
        if (hasCancelButton)
          DialogButton(
            child: Text(
              cancelButtonText ?? 'CANCEL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            onPressed: () => alert = closeAlert(alert),
            color: cancelButtonColor ?? Colors.red,
          ),
        DialogButton(
          child: Text(
            buttonText ?? 'OKAY',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          onPressed: buttonWillClick
              ? () {
                  if (canDismiss) alert = closeAlert(alert);
                  if (hasCancelButton && !buttonWillPop) onPop = null;
                  if (onClick != null) onClick();
                }
              : null,
          color: buttonColor ?? Colors.green,
        ),
      ],
    );

    if (canDismiss) {
      Future.delayed(
          const Duration(seconds: 5), () => alert = closeAlert(alert));
    }

    await alert!.show();

    if (onPop != null) onPop!();
  }
}
