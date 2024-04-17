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
    _pagingController.addPageRequestListener((page) {
      _fetchPage(page);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _ctrl.getImages(pageKey);
      if (newItems == null) {
        setState(() {
          errorMsg = "Error fetching data from API. Please try again later";
        });
        return;
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
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
          crossAxisCount: MediaQuery.of(context).size.width ~/ 150,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        builderDelegate: PagedChildBuilderDelegate<PixaModel>(
          itemBuilder: (context, item, index) {
            final item = _pagingController.itemList![index];
            final likes = item.likes ?? 0;
            final views = item.views ?? 0;
            final previewUrl = item.previewURL;
            final largeUrl = item.largeImageURL;

            return MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (largeUrl != null) {
                  Get.dialog(
                    FullScreenImageDialog(imageUrl: largeUrl, imageId: item.id),
                  );
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
                  previewUrl ?? "",
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
    _pagingController.dispose();
    super.dispose();
  }
}
