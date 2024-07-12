import 'package:flutter/material.dart';
import 'package:my_note/components/my_long_button.dart';
import 'package:my_note/components/my_textfield2.dart';
import 'package:my_note/services/image_service.dart';
import 'package:my_note/utils/show_loading.dart';

class EditPhotoDetailPage extends StatefulWidget {
  final String docId;
  final String title;
  final String tags;
  final String imageUrl;

  const EditPhotoDetailPage(
      {super.key,
      required this.docId,
      required this.title,
      required this.tags,
      required this.imageUrl});

  @override
  State<EditPhotoDetailPage> createState() => _EditPhotoDetailPageState();
}

class _EditPhotoDetailPageState extends State<EditPhotoDetailPage> {
  // use storage service
  final ImageService _imageService = ImageService();

  // controller
  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    titleController.text = widget.title;
    tagsController.text = widget.tags;
  }

  // update detail
  void updateDetail() async {
    showLoading(context);

    await _imageService.updateImageTags(widget.docId, tagsController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Photo Detail'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image preview
              widget.imageUrl.isNotEmpty
                  ? Center(child: SizedBox(height: 200, child: _buildImage()))
                  : const SizedBox(),

              const SizedBox(
                height: 20,
              ),

              // title textfield
              MyTextfield2(
                  controller: titleController,
                  hintText: 'Title (Choose Image First!)',
                  enabled: false),

              const SizedBox(
                height: 10,
              ),

              // image tag textfield
              MyTextfield2(controller: tagsController, hintText: 'Tags'),

              // example
              const Text('example: paku, paku cacing, hitam'),

              const SizedBox(
                height: 40,
              ),

              // update detail button
              MyLongButton(
                  onTap: () {
                    updateDetail();

                    Navigator.pop(context); // pop loading
                    Navigator.pop(context, 'is string'); // pop screen
                  },
                  color: Colors.green,
                  label: 'Save'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      widget.imageUrl,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.inversePrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Center(
            child: Container(
                color: Colors.grey[500],
                width: double.infinity,
                height: double.infinity,
                child: const Icon(Icons.error)));
      },
    );
  }
}
