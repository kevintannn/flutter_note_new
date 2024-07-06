import 'package:flutter/material.dart';

void showPopUpDialog(BuildContext context, List<Widget>? actions) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Confirm delete note?"),
        actions: actions,
      );
    },
  );
}
