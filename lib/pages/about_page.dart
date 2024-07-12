import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_note/themes/dark_theme.dart';
import 'package:my_note/themes/light_theme.dart';
import 'package:my_note/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // made with love
          const Text("Made with ❤️",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),

          const SizedBox(
            height: 5,
          ),

          // by kevin tan
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("by"),
              SizedBox(
                width: 7,
              ),
              Text("Kevin Tan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ],
          ),

          const SizedBox(
            height: 100,
          ),

          // theme toggle
          CupertinoSwitch(
              activeColor: Colors.grey,
              value: themeProvider.currentTheme == lightTheme,
              onChanged: (value) => themeProvider.toggleTheme())
        ]),
      ),
    );
  }
}
