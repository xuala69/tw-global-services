import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;
  final int? imageId;

  const FullScreenImageDialog(
      {super.key, required this.imageId, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const SizedBox(),
        elevation: 0,
        actions: [
          FloatingActionButton(
            mini: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
            ),
            backgroundColor: Colors.black38,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PhotoView(
        imageProvider: NetworkImage(
          imageUrl,
        ),
      ),
    );
  }
}
