import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  var _theamMode = ThemeMode.system;
  ThemeMode get theamMode => _theamMode;

  void setTheme(theamMode) {
    _theamMode = theamMode;
    notifyListeners();
  }
}
