import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:scraper/scraper.dart';
import 'package:universal_html/controller.dart';

import 'domain_fronting.dart';
import 'package:uri/uri.dart';

void main() async {
  // final urls = [
  //   'https://e-hentai.org/',
  //   'https://e-hentai.org/watched?page=1',
  //   'https://e-hentai.org/watched',
  //   'https://e-hentai.org/watched?f_search=l%3Achinese%24+',
  //   'https://e-hentai.org/watched?f_cats=767&f_search=l%3Achinese%24+',
  //   'https://e-hentai.org/?f_cats=767&f_search=l%3Achinese%24+',
  //   'https://e-hentai.org/non-h',
  //   'https://e-hentai.org/non-h/1',
  //   'https://e-hentai.org/g/2017168/016bd5f624/',
  // ];

  var fileUri =
      Uri.file(Platform.script.toFilePath()).resolve('../rules/eh.yaml');
  final ruleFile = File(fileUri.toFilePath());
  final dio = getDio();

  final controller = ScraperController(
      request: (ScraperController controller, Scraper scraper, Uri uri) async {
    final response = await dio.getUri(uri);
    return response.data;
  });

  controller.addYamlRules(ruleFile.readAsStringSync());
  final parser1 =
      await controller.loadUri(Uri.parse('https://e-hentai.org/non-h'));

  final parser2 = await controller
      .loadUri(Uri.parse('https://e-hentai.org/g/2029065/1e6df31ab8/'));

  print("=================");
  print(JsonEncoder.withIndent('  ').convert(parser1.parse()));

  print(JsonEncoder.withIndent('  ').convert(parser2.parse()));
}

Dio getDio() {
  final dio = Dio();
  dio.options.headers = {
    'cookie': 'sl=dm_2',
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36',
  };

  final hosts = {'e-hentai.org': '37.48.89.16'};

  final domainFronting = DomainFronting(
    dnsLookup: (host) => hosts[host],
  );

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return hosts.containsValue(host);
    };
  };

  domainFronting.bind(dio);
  return dio;
}
