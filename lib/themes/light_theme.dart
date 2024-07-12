import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        surface: Colors.grey.shade300,
        primary: Colors.grey.shade500,
        secondary: Colors.grey.shade300,
        tertiary: Colors.white,
        inversePrimary: Colors.grey.shade900),
    splashColor: Colors.transparent,
    textTheme: ThemeData.light()
        .textTheme
        .apply(bodyColor: Colors.grey[800], displayColor: Colors.black));
