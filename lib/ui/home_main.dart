import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tw_global_services/controllers/image_controller.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/ui/fullscreen_image.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final _pagingController = PagingController<int, PixaModel>(firstPageKey: 1);

  final _ctrl = Get.put(ImageController());
  String? errorMsg;
  final int _pageSize = 20;

  @override
  void initState() {
    // add listener to request more data when needed
    _pagingController.addPageRequestListener((page) {
      //fetch data initially once
      _fetchPage(page);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      //get images from api
      final newItems = await _ctrl.getImages(pageKey);
      // if items are null, show error message
      if (newItems == null) {
        setState(() {
          errorMsg = "Error fetching data from API. Please try again later";
        });
        return;
      }
      //compare returned data length with page size to determine if last page is reached
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        // add items as last page
        _pagingController.appendLastPage(newItems);
      } else {
        // add items to the list and pass next page key to controller to know that more items are available
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      // error occurs and shown to UI
      _pagingController.error = error;
      setState(() {
        errorMsg = "Error fetching data from API. Please try again later catch";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PagedGridView<int, PixaModel>(
        pagingController: _pagingController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // determine width and set cross axis item count accordingly
          crossAxisCount: MediaQuery.of(context).size.width ~/ 150,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        builderDelegate: PagedChildBuilderDelegate<PixaModel>(
          itemBuilder: (context, item, index) {
            //current index item
            final item = _pagingController.itemList![index];
            final likes = item.likes ?? 0;
            final views = item.views ?? 0;
            final previewUrl = item.previewURL;
            // large image for fullscreen view, if null, will use preview image
            final largeUrl = item.largeImageURL ?? previewUrl;

            return MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (largeUrl != null) {
                  Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return FullScreenImageDialog(
                        imageUrl: largeUrl,
                        imageId: item.id,
                      );
                    },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      // animate scale of the dialog when opened and closed
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                  ));
                }
              },
              child: GridTile(
                footer: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              likes.toString(),
                              style: GoogleFonts.roboto(
                                color: Colors.grey[200],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.grey[200],
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              views.toString(),
                              style: GoogleFonts.roboto(
                                color: Colors.grey[200],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.grey[200],
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                child: Image.network(
                  // displays preview image, if null, display default image
                  previewUrl ??
                      "https://cdn.pixabay.com/photo/2024/04/17/08/45/ai-generated-8701693_150.jpg",
                  fit: BoxFit.cover,
                  errorBuilder: (context, data, trace) {
                    return Text("Error $data x $trace");
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // dispose controller when no longer needed
    _pagingController.dispose();
    super.dispose();
  }
}
