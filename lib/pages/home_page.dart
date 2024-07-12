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

  // normal variable
  String docIdToDelete = '';

  // state variables
  String search = '';
  Timer? debounce;
  bool isFirstFetch = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  // change search state
  void handleSearch() {
    setState(() {
      isFirstFetch = false;
    });

    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = searchController.text;
      });
    });
  }

  // show delete pop up
  void showDeleteDialog() {
    showPopUpDialog(context, 'Confirm delete note?', [
      // delete
      MyDialogButton(
          onTap: () {
            Navigator.pop(context);
            showDeleteDialog2();
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

  // show delete pop up
  void showDeleteDialog2() {
    showPopUpDialog(context, 'Double confirm delete note?', [
      // delete
      MyDialogButton(
          onTap: () {
            deleteNote();
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
  void deleteNote() async {
    await _noteService.deleteNote(docIdToDelete);
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
        child: StreamBuilder(
          stream: _noteService.getNotesStream(),
          builder: (context, snapshot) {
            // error
            if (snapshot.hasError) {
              return const Text("Error");
            }

            // loading
            if (isFirstFetch &&
                snapshot.connectionState == ConnectionState.waiting) {
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

            int noteCount = snapshot.data!.docs.length;

            // return list view
            return Column(
              children: [
                // header
                Row(
                  children: [
                    const Text(
                      "Notes",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " ($noteCount)",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                // search bar
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

                    setState(() {
                      search = '';
                    });
                    searchController.clear();
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                // list view and not found if it's empty
                filteredNotes.isEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: const Text("No Note"))
                    : Expanded(child: _buildNoteList(filteredNotes))
              ],
            );
          },
        ),
      ),
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
                  onPressed: (context) {
                    docIdToDelete = doc.id;
                    showDeleteDialog();
                  },
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotePage(
                              noteId: doc.id,
                              searchFromHome: search,
                            ))).then((_) {
                  setState(() {
                    search = '';
                  });
                  searchController.clear();
                });
              },
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
