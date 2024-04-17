import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/utils/constants.dart';

class ImageController extends GetxController {
  static ImageController get to => Get.find();
  final dio = Dio();

  Future<List<PixaModel>?> getImages(int pageNo) async {
    try {
      final resp = await dio.get(
        "${Strings.apiUrl}?key=${Strings.apiToken}",
        queryParameters: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      if (resp.statusCode == 200) {
        List<PixaModel> hits = [];
        final js = (resp.data);
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
