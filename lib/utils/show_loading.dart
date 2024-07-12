import 'package:flutter/material.dart';
import 'package:my_note/components/my_loading_spinner.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const MyLoadingSpinner();
    },
  );
}
