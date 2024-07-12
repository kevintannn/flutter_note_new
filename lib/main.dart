import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_note/components/my_loading_spinner.dart';
import 'package:my_note/firebase_options.dart';
import 'package:my_note/pages/router_page.dart';
import 'package:my_note/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.currentTheme,
                  home: const RouterPage(),
                );
              },
            ),
          );
        } else {
          return const MyLoadingSpinner();
        }
      },
    );
  }
}
