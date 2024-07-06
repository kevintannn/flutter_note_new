import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyNoteCard extends StatelessWidget {
  final String title;
  final String note;
  final Timestamp? timestamp;

  const MyNoteCard(
      {super.key,
      required this.title,
      required this.note,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    String timeAgo = '';

    if (timestamp != null) {
      final DateTime dateTime = timestamp!.toDate();
      timeAgo = timeago.format(dateTime);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // note title
          Text(
            title.isEmpty ? "No Title" : title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),

          const SizedBox(
            height: 10,
          ),

          // note texts
          Text(
            note.isEmpty ? "Note is empty" : note,
            maxLines: 3,
          ),

          const SizedBox(
            height: 15,
          ),

          // timestamp
          Text(
            timeAgo,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
