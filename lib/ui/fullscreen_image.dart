import 'package:flutter/cupertino.dart';
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
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
