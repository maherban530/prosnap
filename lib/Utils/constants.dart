import 'package:flutter/material.dart';

class AgoraData {
  static const appId = '50bb2c4882cc4da6915175f607cab484';
  static const tokenUrl =
      'https://agora-node-tokenserver.maherbanhusensu.repl.co/access_token?channelName=';
  // static const token =
  //     '007eJxTYLC+PDk21qW1XOxE1+uvWc5lff8eheo+Dlj6Oueoc+iNTVUKDKYGSUlGySYWFkbJySYpiWaWhqaG5qZpZgbmyYlJJhYmct8SkxsCGRmuxfMzMTJAIIjPzpCckVjiWFDAwAAANB4h4w==';
}

class Constants {
  static const String USER_ID = "userId";
  static const String TITLE = "Magic Kass";

  static const DEFAULT_SCREEN_PADDING = 8.0;
  static const DEFAULT_TEXT_FIELD_PADDING = 32.0;
  static const DEFAULT_RAISED_BUTTON_ELEVATION = 8.0;
  static const DEFAULT_ROUND_BUTTON_CORNER_RADIUS = 20.0;
}

class ApplicationTexts {
  static const String buttonName = "Submit";
  static const String signUpButtonName = "SignUp";
  static const String continueButtonName = "Continue";

  static const String logInButtonName = "LogIn";

  static const String firstName = "First Name";
  static const String lastName = "Last Name";

  static const String firstNameIsEmpty = "First Name is Empty";
  static const String phoneNumber = "Phone Number";
  static const String phoneNumberError = "Phone Number Not Valid";
  static const String email = "Email";
  static const String emailAndPhone = "Email/Phone Number";

  static const String emailIsEmpty = "Email is Empty";
  static const String password = "Password";
  static const String passwordIsEmpty = "Password is Empty";
}

class AppColors {
  static const Color tealColor = Colors.teal;
  static const Color whiteColor = Color(0xFFF4F4F4);
  static const Color greyColor = Colors.grey;
  static const Color blueColor = Colors.blue;
}
