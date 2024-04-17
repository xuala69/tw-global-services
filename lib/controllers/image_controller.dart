import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/utils/constants.dart';

class ImageController extends GetxController {
  static ImageController get to => Get.find();

  Future<List<PixaModel>?> getImages(int pageNo) async {
    try {
      // final model = PixaModel(
      //   id: 2,
      //   likes: 1,
      //   views: 2,
      //   largeImageURL: Strings.sampleImg,
      //   previewURL: Strings.sampleImg,
      // );
      // return [model];

      final resp = await http.get(
        Uri.parse("${Strings.apiUrl}?key=${Strings.apiToken}"),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*'
        },
      );
      if (resp.statusCode == 200) {
        List<PixaModel> hits = [];
        final js = jsonDecode(resp.body);
        final List hitsJs = js['hits'];
        for (var hit in hitsJs) {
          final model = PixaModel.fromJson(hit);
          hits.add(model);
        }
        return hits;
      } else {
        log("Error responded from server: ${resp.body}");
        return null;
      }
    } catch (e) {
      log("Error getting Images: $e");
      return null;
    }
  }
}
