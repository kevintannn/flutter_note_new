import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_note/components/my_loading_spinner.dart';
import 'package:my_note/components/my_textfield.dart';
import 'package:my_note/services/note_service.dart';

class NotePage extends StatefulWidget {
  final String? noteId;

  const NotePage({super.key, this.noteId});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // use note service
  final NoteService _noteService = NoteService();

  bool showLoading = false;
  Timer? debounce;
  String? _noteId;
  bool isFirstFetch = true;
  bool showSearch = false;
  String search = '';

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;

    debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        isFirstFetch = false;
      });
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  // update note on note change
  void onNoteChanged() {
    setState(() {
      isFirstFetch = false;
      showLoading = true;
    });

    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(seconds: 1), () async {
      if (titleController.text.isEmpty && noteController.text.isEmpty) {
        setState(() {
          showLoading = false;
        });
        return;
      }

      String? noteIdFromSaveNote = await saveNote();

      setState(() {
        _noteId = noteIdFromSaveNote;
        showLoading = false;
      });
    });
  }

  // toggle search inside note
  void toggleSearch() {
    setState(() {
      showSearch = !showSearch;
      search = '';
    });

    searchController.clear();
  }

  // close search box
  void closeSearch() {
    if (showSearch) {
      setState(() {
        showSearch = false;
        search = '';
      });

      searchController.clear();
    }
  }

  // check if note is empty
  bool isNoteEmpty() {
    return noteController.text.isEmpty;
  }

  // debounce search
  void handleSearch() {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(seconds: 1), () {
      search = searchController.text;
    });
  }

  // save note
  Future<String?> saveNote() async {
    return await _noteService.saveNote(
        titleController.text, noteController.text, _noteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: _buildAppBarLeading(),
          actions: [
            isNoteEmpty()
                ? const SizedBox()
                : IconButton(
                    onPressed: toggleSearch, icon: const Icon(Icons.search))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: _buildFloatingActionButton(),
        body: PopScope(
          canPop: !showLoading,
          child: _noteId == null ? _buildEmptyNote() : _buildExistingNote(),
        ));
  }

  Widget _buildAppBarLeading() {
    return showLoading
        ? const SizedBox(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(
                  strokeWidth: 2.0, color: Colors.white),
            ),
          )
        : IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back));
  }

  Widget _buildFloatingActionButton() {
    return !showSearch
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.only(right: 30),
            child: SizedBox(
              width: 250,
              height: 90,
              child: MyTextField(
                textController: searchController,
                hintText: 'Search note',
                type: 2,
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),
          );
  }

  Widget _buildEmptyNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // title text field
          _buildTitleTextFieldWidget(),

          // note textfield
          _buildNoteTextFieldWidget(),
        ],
      ),
    );
  }

  // future
  Widget _buildExistingNote() {
    return FutureBuilder(
      future: _noteService.getNote(_noteId as String),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return const Text('Error');
        }

        // loading
        // i implement it this way to not let
        // text edit trigger state change and
        // rebuild this widget
        if (isFirstFetch) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyLoadingSpinner();
          }

          titleController.text = snapshot.data!['title'];
          noteController.text = snapshot.data!['note'];
        }

        // return item
        return _buildEmptyNote();
      },
    );
  }

  Widget _buildTitleTextFieldWidget() {
    return TextField(
      controller: titleController,
      onTap: closeSearch,
      onChanged: (value) => onNoteChanged(),
      decoration: const InputDecoration(
        hintText: 'Enter note title',
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      cursorColor: Theme.of(context).colorScheme.inversePrimary,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildNoteTextFieldWidget() {
    return showSearch
        ? Expanded(
            child: GestureDetector(
              onTap: closeSearch,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 13),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    child: RichText(
                      text: _buildHighlightedText(noteController.text),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Expanded(
            child: TextField(
                controller: noteController,
                onTap: closeSearch,
                onChanged: (value) => onNoteChanged(),
                decoration: const InputDecoration(
                    hintText: 'Write note here',
                    hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
                keyboardType: TextInputType.multiline,
                maxLines: null));
  }

  TextSpan _buildHighlightedText(String text) {
    String localText = text.toLowerCase();
    String localSearchTerm = search.toLowerCase();
    TextStyle textStyle = TextStyle(
        fontSize: 16,
        letterSpacing: 0.5,
        height: 1.5,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300]
            : Colors.grey[800]);

    if (search.isEmpty) {
      return TextSpan(text: text, style: textStyle);
    }

    List<InlineSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while (
        (indexOfHighlight = localText.indexOf(localSearchTerm, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
            text: text.substring(start, indexOfHighlight), style: textStyle));
      }

      start = indexOfHighlight + search.length;

      spans.add(WidgetSpan(
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          child:
              Text(text.substring(indexOfHighlight, start), style: textStyle),
        ),
      ));
    }

    spans.add(TextSpan(text: text.substring(start), style: textStyle));

    return TextSpan(children: spans);
  }
}
