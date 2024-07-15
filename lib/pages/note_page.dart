import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_note/components/my_loading_spinner.dart';
import 'package:my_note/components/my_textfield.dart';
import 'package:my_note/services/note_service.dart';

class NotePage extends StatefulWidget {
  final String? noteId;
  final String? searchFromHome;

  const NotePage({super.key, this.noteId, this.searchFromHome});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  // use note service
  final NoteService _noteService = NoteService();

  // text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  // final ScrollController scrollController = ScrollController();

  // focus node
  final FocusNode searchFocusNode = FocusNode();

  // state variables
  bool showLoading = false;
  Timer? debounce;
  String? _noteId;
  bool isFirstFetch = true;
  bool showSearch = false;
  String search = '';
  double textScaleFactor = 1;
  bool searchNotFound = false;

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;
    searchController.text = widget.searchFromHome ?? '';
    search = searchController.text;

    if (search.isNotEmpty) {
      showSearch = true;
    }

    debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        isFirstFetch = false;
        if (search.isNotEmpty) {
          showSnackbar();
        }
      });
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchFocusNode.dispose();
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
  void toggleSearch() async {
    setState(() {
      showSearch = !showSearch;
      search = '';
      searchNotFound = false;
    });

    if (showSearch) {
      Timer(const Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(searchFocusNode);
      });

      showSnackbar();
    }

    searchController.clear();
  }

  // close search box
  void closeSearch() {
    if (showSearch) {
      setState(() {
        showSearch = false;
        search = '';
        searchNotFound = false;
      });

      searchController.clear();
    }
  }

  // check if note is empty
  bool isNoteEmpty() {
    return noteController.text.isEmpty;
  }

  // show snackbar
  void showSnackbar() {
    const snackBar = SnackBar(
      content: Text('Double tap to close search'),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // save note
  Future<String?> saveNote() async {
    return await _noteService.saveNote(
        titleController.text, noteController.text, _noteId);
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaler.scale(1) / 1;

    return Scaffold(
        appBar: AppBar(
          leading: _buildAppBarLeading(),
          actions: [
            isNoteEmpty()
                ? const SizedBox()
                : IconButton(
                    onPressed: toggleSearch,
                    icon: showSearch
                        ? const Icon(Icons.close)
                        : const Icon(Icons.search))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: _buildFloatingActionButton(),
        body: PopScope(
          canPop: !showLoading,
          child: _noteId == null ? _buildEmptyNote() : _buildExistingNote(),
        ));
  }

  // build app bar leading
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

  // build floating action button
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
                focusNode: searchFocusNode,
                hintText: 'Search note',
                type: 2,
                onChanged: (value) {
                  setState(() {
                    search = value;

                    if (!noteController.text
                        .toLowerCase()
                        .contains(search.toLowerCase())) {
                      searchNotFound = true;
                    } else {
                      searchNotFound = false;
                    }
                  });
                },
              ),
            ),
          );
  }

  // build empty note
  Widget _buildEmptyNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // title text field
          _buildTitleTextFieldWidget(),

          showSearch && searchNotFound && search.isNotEmpty
              ? const Text('Search not found!', style: TextStyle(fontSize: 10))
              : const SizedBox(),

          // note textfield
          _buildNoteTextFieldWidget(),
        ],
      ),
    );
  }

  // build existing note future
  Widget _buildExistingNote() {
    return FutureBuilder(
      key: const PageStorageKey('note'),
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

  // build title textfield
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
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
    );
  }

  // build note textfield
  Widget _buildNoteTextFieldWidget() {
    return showSearch
        ? Expanded(
            child: GestureDetector(
              onDoubleTap: closeSearch,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 14, bottom: 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    child: RichText(
                      textScaler: TextScaler.linear(textScaleFactor),
                      text: _buildHighlightedText(noteController.text),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Expanded(
            child: SingleChildScrollView(
            child: TextField(
                key: const PageStorageKey('note'),
                controller: noteController,
                onChanged: (value) => onNoteChanged(),
                decoration: const InputDecoration(
                    hintText: 'Write note here',
                    hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null),
          ));
  }

  // build highlighted search term
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
    TextStyle textStyle2 = const TextStyle(
        fontSize: 15, letterSpacing: 0.5, height: 1.5, color: Colors.black);

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
          color: Colors.yellow,
          child:
              Text(text.substring(indexOfHighlight, start), style: textStyle2),
        ),
      ));
    }

    spans.add(TextSpan(text: text.substring(start), style: textStyle));

    return TextSpan(children: spans);
  }
}
