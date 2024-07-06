import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  // user firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get notes stream
  Stream<QuerySnapshot> getNotesStream() {
    return _firestore
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // save note
  Future<String?> saveNote(String title, String note, String? noteId) async {
    try {
      if (noteId == null) {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('notes').add({
          'title': title,
          'note': note,
          'timestamp': FieldValue.serverTimestamp(),
        });

        String newNoteId = docRef.id;
        return newNoteId;
      } else {
        await FirebaseFirestore.instance.collection('notes').doc(noteId).set({
          'title': title,
          'note': note,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return noteId;
      }
    } catch (e) {
      print('Error saving note: $e');
      return null;
    }
  }

  // get individual note
  Future<DocumentSnapshot> getNote(String docId) async {
    return await _firestore.collection('notes').doc(docId).get();
  }

  // delete note
  Future<void> deleteNote(String docId) async {
    await _firestore.collection('notes').doc(docId).delete();
  }
}
