import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/utils/constants.dart';

class ImageController extends GetxController {
  static ImageController get to => Get.find();
  final dio = Dio();

  Future<List<PixaModel>?> getImages(int pageNo) async {
    try {
      return [
        PixaModel(
          id: 1,
          previewURL:
              "https://cdn.pixabay.com/photo/2024/02/25/10/11/forsythia-8595521_150.jpg",
          largeImageURL:
              "https://cdn.pixabay.com/photo/2024/02/25/10/11/forsythia-8595521_150.jpg",
          views: 23,
          likes: 455,
        ),
        PixaModel(
          id: 2,
          previewURL:
              "https://cdn.pixabay.com/photo/2024/02/25/10/11/forsythia-8595521_150.jpg",
          largeImageURL:
              "https://cdn.pixabay.com/photo/2024/02/25/10/11/forsythia-8595521_150.jpg",
          views: 235,
          likes: 45,
        ),
      ];
      // final model = PixaModel(
      //   id: 2,
      //   likes: 1,
      //   views: 2,
      //   largeImageURL: Strings.sampleImg,
      //   previewURL: Strings.sampleImg,
      // );
      // return [model];

      final resp = await dio.get(
        "${Strings.apiUrl}?key=${Strings.apiToken}",
        queryParameters: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          "X-Requested-With": "XMLHttpRequest",
        },
      );

      // final resp = await http.get(
      //   Uri.parse("${Strings.apiUrl}?key=${Strings.apiToken}"),
      //   headers: {
      //     "Access-Control-Allow-Origin": "*",
      //     'Content-Type': 'application/json',
      //     'Accept': '*/*'
      //   },
      // );
      if (resp.statusCode == 200) {
        List<PixaModel> hits = [];
        final js = jsonDecode(resp.data);
        final List hitsJs = js['hits'];
        for (var hit in hitsJs) {
          final model = PixaModel.fromJson(hit);
          hits.add(model);
        }
        return hits;
      } else {
        log("Error responded from server: ${resp.data}");
        return null;
      }
    } catch (e) {
      log("Error getting Images: $e");
      return null;
    }
  }
}
