import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get images
  Stream<QuerySnapshot> getImagesStream() {
    return _firestore
        .collection('images')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // get individual image
  Future<DocumentSnapshot<Map<String, dynamic>>> getImageByDocId(String docId) {
    return _firestore.collection('images').doc(docId).get();
  }

  // upload image
  Future uploadImageToFirebaseAndGetImageUrl(File? image) async {
    if (image == null) return;

    try {
      String fileName = p.basename(image.path);
      Reference firebaseStorageRef = _storage.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => print('File Uploaded'));
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // store image data to firestore
  Future<void> storeImageDataToFirestore(
      String title, String tags, String imageUrl) async {
    try {
      CollectionReference imagesRef = _firestore.collection('images');
      await imagesRef.add({
        'title': title,
        'tags': tags,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Image data stored in Firestore');
    } catch (e) {
      print('Error storing image URL: $e');
    }
  }

  // update image tags
  Future<void> updateImageTags(String docId, String tags) async {
    try {
      await _firestore.collection('images').doc(docId).update({'tags': tags});

      print('Image tags updated to Firestore');
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  // delete image data
  Future<void> deleteNote(String docId, String fileName) async {
    try {
      await _firestore.collection('images').doc(docId).delete();
      print("Document deleted!");
    } catch (e) {
      print('Error deleting document: $e');
    }

    try {
      await _storage.ref().child('/uploads/$fileName').delete();
      print("File deleted!");
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
