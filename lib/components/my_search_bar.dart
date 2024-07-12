import 'package:flutter/material.dart';
import 'package:my_note/components/my_textfield.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String hintText;

  const MySearchBar(
      {super.key,
      required this.searchController,
      this.onChanged,
      this.onTap,
      required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // search box
        Expanded(
          child: MyTextField(
            textController: searchController,
            hintText: hintText,
            onChanged: onChanged,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        // add new note button
        GestureDetector(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add)),
        )
      ],
    );
  }
}
