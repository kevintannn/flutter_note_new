import 'package:flutter/material.dart';

class MyDialogButton extends StatelessWidget {
  final void Function()? onTap;
  final Color? buttonColor;
  final Color? textColor;
  final String label;

  const MyDialogButton(
      {super.key,
      required this.onTap,
      required this.buttonColor,
      required this.textColor,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: buttonColor, borderRadius: BorderRadius.circular(100)),
        child: Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
