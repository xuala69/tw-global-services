import 'package:flutter/material.dart';

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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Transform.scale(
        scale: 1.5,
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, data, trace) {
                return Text("Error $data x $trace");
              },
            ),
          ),
        ),
      ),
    );
  }
}
