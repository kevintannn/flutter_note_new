import 'package:flutter/material.dart';

class MyTextfield2 extends StatelessWidget {
  final TextEditingController? controller;
  final bool? enabled;
  final String hintText;

  const MyTextfield2(
      {super.key, this.controller, this.enabled, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled ?? true,
      decoration: InputDecoration(
          filled: true,
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.inversePrimary)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 2, color: Theme.of(context).colorScheme.primary))),
    );
  }
}
