import 'package:flutter/material.dart';

void showPopUpDialog(
    BuildContext context, String content, List<Widget>? actions) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(content),
        actions: actions,
      );
    },
  );
}
