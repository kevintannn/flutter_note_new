import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(25),
        child: TextField(
            // maxLines: null,
            // keyboardType: TextInputType.multiline,
            ),
      ),
    );
  }
}
