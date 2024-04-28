import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tw_global_services/controllers/image_controller.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/ui/fullscreen_image.dart';
import 'package:tw_global_services/utils/search_delegate.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final _pagingController = PagingController<int, PixaModel>(firstPageKey: 1);

  final _ctrl = Get.put(ImageController());

  final controller = TextEditingController();
  String? errorMsg;
  final int _pageSize = 200;

  final RxString _searchText = "".obs;

  @override
  void initState() {
    debounce(
      _searchText,
      (text) {
        log("Debounced function");

        _pagingController.refresh();
        log("Refresh called ");
      },
      time: const Duration(milliseconds: 500),
    );
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
      final newItems = await _ctrl.getImages(
        pageKey,
        perPage: _pageSize,
        search: _searchText.value,
      );
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
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchText.value = "";
                controller.clear();
              },
            ),
          ),
          onChanged: (value) {
            _searchText.value = value;
          },
        ),
      ),
      body: PagedGridView<int, PixaModel>(
        physics: const BouncingScrollPhysics(),
        pagingController: _pagingController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // determine width and set cross axis item count accordingly
          crossAxisCount: MediaQuery.of(context).size.width ~/ 250,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
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
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.grey[200],
                              size: 17,
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
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.grey[200],
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        previewUrl ??
                            "https://cdn.pixabay.com/photo/2024/04/17/08/45/ai-generated-8701693_150.jpg",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
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

class _CustomSearchDelegate extends StatefulWidget {
  final TextEditingController searchController;
  final List<String> searchResults;
  final Function(String) onItemTapped;

  const _CustomSearchDelegate({
    required this.searchController,
    required this.searchResults,
    required this.onItemTapped,
  });

  @override
  __CustomSearchDelegateState createState() => __CustomSearchDelegateState();
}

class __CustomSearchDelegateState extends State<_CustomSearchDelegate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: widget.searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.searchController.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.searchResults
            .where((item) => item
                .toLowerCase()
                .contains(widget.searchController.text.toLowerCase()))
            .length,
        itemBuilder: (context, index) {
          final filteredItem = widget.searchResults
              .where((item) => item
                  .toLowerCase()
                  .contains(widget.searchController.text.toLowerCase()))
              .toList()[index];
          return ListTile(
            title: Text(filteredItem),
            onTap: () {
              widget.onItemTapped(filteredItem);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
