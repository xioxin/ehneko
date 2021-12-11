import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scraper/scraper.dart';
import 'package:path/path.dart' as p;

import 'http.dart';

ScraperController? controller;

ScraperController getScraperController() {
  if (controller != null) return controller!;
  final filePath = p.join(Directory.current.path, './rules/eh.scraper.yaml');
  final ruleFile = File(filePath);
  final dio = getDio();
  controller = ScraperController(request: (ScraperController controller,
      Scraper scraper, Uri uri, Map<String, dynamic>? extra) async {
    final response = await dio.getUri(uri, options: Options(extra: extra));
    return response.data;
  });
  controller!.addYamlRules(ruleFile.readAsStringSync());
  return controller!;
}

