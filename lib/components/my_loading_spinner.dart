import 'package:flutter/material.dart';

class MyLoadingSpinner extends StatelessWidget {
  const MyLoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: Theme.of(context).colorScheme.inversePrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ));
  }
}
