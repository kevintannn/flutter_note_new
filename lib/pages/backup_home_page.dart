import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_note/components/my_dialog_button.dart';
import 'package:my_note/components/my_loading_spinner.dart';
import 'package:my_note/components/my_note_card.dart';
import 'package:my_note/components/my_search_bar.dart';
import 'package:my_note/pages/note_page.dart';
import 'package:my_note/services/note_service.dart';
import 'package:my_note/utils/show_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  // use note service
  final NoteService _noteService = NoteService();

  String search = '';
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  // change search state
  void handleSearch() {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = searchController.text;
      });
    });
  }

  // show delete pop up
  void showDeleteDialog(String docId) {
    showPopUpDialog(context, 'Confirm delete note?', [
      // delete
      MyDialogButton(
          onTap: () {
            deleteNote(docId);
            Navigator.pop(context);
          },
          buttonColor: Colors.red,
          textColor: Colors.white,
          label: 'Delete'),

      // cancel
      MyDialogButton(
          onTap: () => Navigator.pop(context),
          buttonColor: Theme.of(context).colorScheme.secondary,
          textColor: Colors.white,
          label: 'Cancel'),
    ]);
  }

  // delete note
  void deleteNote(String docId) async {
    await _noteService.deleteNote(docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            const Row(
              children: [
                Text(
                  "Notes",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  " (275)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            // search box
            MySearchBar(
              searchController: searchController,
              onChanged: (value) => handleSearch(),
              hintText: 'Search notes',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotePage(),
                    ));
              },
            ),

            const SizedBox(
              height: 10,
            ),

            // notes list view
            Expanded(child: _buildNoteStream())
          ],
        ),
      ),
    );
  }

  // build note stream builder
  Widget _buildNoteStream() {
    return StreamBuilder(
      stream: _noteService.getNotesStream(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyLoadingSpinner();
        }

        // search logic
        List<QueryDocumentSnapshot> filteredNotes =
            snapshot.data!.docs.where((doc) {
          String title = doc['title'].toString().toLowerCase();
          String note = doc['note'].toString().toLowerCase();

          return title.contains(search.toLowerCase()) ||
              note.contains(search.toLowerCase());
        }).toList();

        // not found text if filtered note is empty
        if (filteredNotes.isEmpty) {
          return const Text("Not found!");
        }

        // return list view
        return _buildNoteList(filteredNotes);
      },
    );
  }

  // build note listview
  Widget _buildNoteList(List<QueryDocumentSnapshot> filteredNotes) {
    return ListView(
      children: filteredNotes.map<Widget>((doc) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Slidable(
            closeOnScroll: true,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => showDeleteDialog(doc.id),
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotePage(
                            noteId: doc.id,
                          ))),
              child: MyNoteCard(
                title: doc['title'],
                note: doc['note'],
                timestamp: doc['timestamp'],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
