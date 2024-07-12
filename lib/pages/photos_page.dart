import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_note/components/my_loading_spinner.dart';
import 'package:my_note/components/my_search_bar.dart';
import 'package:my_note/pages/photo_detail_page.dart';
import 'package:my_note/pages/upload_image_page.dart';
import 'package:my_note/services/image_service.dart';
import 'package:my_note/utils/get_formatted_tags.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  // use storage service
  final ImageService _imageService = ImageService();

  // controller
  final TextEditingController searchController = TextEditingController();

  // state variables
  String search = '';
  Timer? debounce;
  bool isFirstFetch = true;

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  // handle search change
  void handleSearchChange() {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isFirstFetch = false;
        search = searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Photos"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // search box
            Padding(
              padding: const EdgeInsets.all(10),
              child: MySearchBar(
                searchController: searchController,
                hintText: 'Search photos by tag',
                onChanged: (value) => handleSearchChange(),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadImagePage()));
                },
              ),
            ),

            // image grids
            Expanded(child: _buildImagesStream())
          ],
        ));
  }

  Widget _buildImagesStream() {
    return StreamBuilder(
      stream: _imageService.getImagesStream(),
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

        // search by tags
        List<QueryDocumentSnapshot<Object?>> filteredDocs =
            snapshot.data!.docs.where((doc) {
          List<String> splittedSearch = search.toLowerCase().split(' ');
          List<String> splittedTags = getFormattedTags(doc['tags']);

          bool matchFound = splittedSearch
              .every((term) => splittedTags.any((tag) => tag.contains(term)));

          return matchFound;
        }).toList();

        // return grid view
        return filteredDocs.isEmpty
            ? const Center(
                child: Text("No Image"),
              )
            : _buildImagesGrid(context, filteredDocs);
      },
    );
  }

  Widget _buildImagesGrid(
      BuildContext context, List<QueryDocumentSnapshot<Object?>> filteredDocs) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      children: filteredDocs.map((doc) {
        // get individual image
        QueryDocumentSnapshot<Object?> image = doc;

        // return grid tile
        return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoDetailPage(
                            docId: image.id,
                          )));

              // clear search
              searchController.clear();
              setState(() {
                search = '';
              });
            },
            child: _buildGridTile(image['image_url']));
      }).toList(),
    );
  }

  Widget _buildGridTile(String imageUrl) {
    return GridTile(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
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
      ),
    );
  }
}
