import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tw_global_services/models/pixa_model.dart';
import 'package:tw_global_services/utils/constants.dart';

class ImageController extends GetxController {
  static ImageController get to => Get.find();
  final dio = Dio();

  Future<List<PixaModel>?> getImages(int pageNo,
      {required int perPage, required String search}) async {
    try {
      log("PAGE NO:$pageNo Q:$search");
      final resp = await dio.get(
        "${Strings.apiUrl}?key=${Strings.apiToken}&page=$pageNo&per_page=$perPage&q=$search",
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
        return [];
      }
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data;
        if (msg is String && msg.contains("out of valid range.")) {
          log("out of range");
          return [];
        }
        return null;
      }
      log("Error getting Images: $e");
      return null;
    }
  }
}
