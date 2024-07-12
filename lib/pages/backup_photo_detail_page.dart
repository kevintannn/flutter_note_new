import 'package:flutter/material.dart';
import 'package:my_note/pages/edit_photo_detail_page.dart';
import 'package:my_note/services/image_service.dart';
import 'package:my_note/utils/get_formatted_tags.dart';
import 'package:my_note/utils/show_loading.dart';
import 'package:photo_view/photo_view.dart';

class PhotoDetailPage extends StatelessWidget {
  final String docId;
  final String title;
  final String tags;
  final String imageUrl;

  PhotoDetailPage(
      {super.key,
      required this.docId,
      required this.title,
      required this.tags,
      required this.imageUrl});

  // use storage service
  final ImageService _imageService = ImageService();

  // show modal bottom sheet
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildBottomSheet(context);
      },
    );
  }

  // delete photo
  void deletePhoto(BuildContext context) async {
    showLoading(context);

    await _imageService.deleteNote(docId, title);

    Navigator.pop(context); // pop loading
    Navigator.pop(context); // pop bottom sheet
    Navigator.pop(context); // pop screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () => showBottomSheet(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.more_horiz),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Positioned.fill(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error),
              ),
            ),
          ),

          // floating back button
          Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ))
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image title
          Text(title),

          const SizedBox(
            height: 10,
          ),

          // image tags
          Expanded(
            child: _buildTagList(),
          ),

          const SizedBox(
            height: 10,
          ),

          // edit and delete buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // edit
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPhotoDetailPage(
                            docId: docId,
                            title: title,
                            tags: tags,
                            imageUrl: imageUrl),
                      ));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              // delete
              GestureDetector(
                onTap: () {
                  deletePhoto(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagList() {
    return ListView(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 1,
          children: getFormattedTags(tags).map((item) {
            return Chip(label: Text(item.toLowerCase()));
          }).toList(),
        )
      ],
    );
  }
}
