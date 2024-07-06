import 'package:flutter/material.dart';
import 'package:my_note/pages/home_page.dart';
import 'package:my_note/pages/photos_page.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  final List<Widget> _pages = [const HomePage(), const PhotosPage()];
  int _activePageIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _activePageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_activePageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activePageIndex,
        elevation: 0,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) => navigateBottomBar(index),
        enableFeedback: false,
        items: const [
          // home
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),

          // photos
          BottomNavigationBarItem(label: "Photos", icon: Icon(Icons.photo)),
        ],
      ),
    );
  }
}
