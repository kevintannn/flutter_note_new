import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? textController;
  final String hintText;
  final void Function(String)? onChanged;
  final int? type;

  const MyTextField(
      {super.key,
      this.textController,
      required this.hintText,
      this.onChanged,
      this.type});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      cursorColor: Theme.of(context).colorScheme.inversePrimary,
      cursorWidth: 1,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
              borderSide: type == 2
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(8)),
          hintStyle: const TextStyle(fontWeight: FontWeight.normal),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true),
      onChanged: onChanged,
    );
  }
}
