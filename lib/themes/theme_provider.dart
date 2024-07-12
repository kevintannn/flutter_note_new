import 'package:flutter/material.dart';
import 'package:my_note/themes/dark_theme.dart';
import 'package:my_note/themes/light_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = darkTheme;

  // constructor
  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isLightTheme = prefs.getBool('isLightTheme') ?? false;
    _currentTheme = isLightTheme ? lightTheme : darkTheme;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightTheme', _currentTheme == lightTheme);
  }
}
