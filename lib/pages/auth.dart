import 'package:biblechamps/services/auth.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      onLogin: (LoginData data) =>
          AuthService().logIn(data.name, data.password),
      onSignup: (SignupData data) =>
          AuthService().register(data.name, data.password),
      onRecoverPassword: (String name) => AuthService().resetPassword(name),
      onSubmitAnimationCompleted: () => UiService().nextPage(context),
      messages: LoginMessages(
        userHint: 'Email',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm password',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        forgotPasswordButton: 'Forgot password?',
        recoverPasswordButton: 'RECOVER',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Passwords do not match!',
        recoverPasswordIntro: '',
        recoverPasswordDescription:
            'A link would be sent to the email provided, follow that link to set your new password',
        recoverPasswordSuccess: 'Recovery mail sent',
      ),
    );
  }
}
