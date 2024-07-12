import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_note/components/my_long_button.dart';
import 'package:my_note/components/my_textfield2.dart';
import 'package:my_note/services/image_service.dart';
import 'package:my_note/utils/show_loading.dart';
import 'package:path/path.dart' as p;

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  // controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  // use storage service
  final ImageService _imageService = ImageService();

  File? image;

  // upload to firebase
  void uploadImage() async {
    if (titleController.text.isEmpty || tagController.text.isEmpty) {
      return;
    }

    showLoading(context);

    String imageUrl =
        await _imageService.uploadImageToFirebaseAndGetImageUrl(image);

    if (imageUrl.isNotEmpty) {
      await _imageService.storeImageDataToFirestore(
          titleController.text, tagController.text, imageUrl);
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  // pick image from gallery
  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        titleController.text = p.basename(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // upload image button
              MyLongButton(
                  onTap: pickImage, color: Colors.blue, label: 'Choose Image'),

              const SizedBox(
                height: 20,
              ),

              // image preview
              image != null
                  ? Center(
                      child: SizedBox(
                          height: 200, child: Image.file(image as File)))
                  : const SizedBox(),

              const SizedBox(
                height: 10,
              ),

              // title textfield
              MyTextfield2(
                controller: titleController,
                hintText: 'Title (Choose Image First!)',
                enabled: false,
              ),

              const SizedBox(
                height: 10,
              ),

              // image tag textfield
              MyTextfield2(
                controller: tagController,
                hintText: 'Tags',
              ),

              // example
              const Text('example: paku, paku cacing, hitam'),

              const SizedBox(
                height: 40,
              ),

              // upload button
              MyLongButton(
                  onTap: uploadImage,
                  color: Colors.green,
                  label: 'Upload Image'),
            ],
          ),
        ),
      ),
    );
  }
}
