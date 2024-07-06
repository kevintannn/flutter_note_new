import 'package:flutter/material.dart';
import 'package:my_note/components/my_textfield.dart';
import 'package:my_note/pages/note_page.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String)? onChanged;

  const MySearchBar(
      {super.key, required this.searchController, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // search box
        Expanded(
          child: MyTextField(
            textController: searchController,
            hintText: 'Search notes',
            onChanged: onChanged,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        // add new note button
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotePage(),
                ));
          },
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add)),
        )
      ],
    );
  }
}
