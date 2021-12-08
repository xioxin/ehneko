import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:eh/log.dart';
import 'package:scraper/scraper.dart';
import 'package:dio_domain_fronting/dio_domain_fronting.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'eh.dart';

ScraperController? controller;

ScraperController getScraperController() {
  if (controller != null) return controller!;
  var fileUri = Uri.file(Platform.script.toFilePath())
      .resolve('../rules/eh.scraper.yaml');
  final ruleFile = File(fileUri.toFilePath());
  final dio = getDio();
  controller = ScraperController(
      request: (ScraperController controller, Scraper scraper, Uri uri) async {
    final response = await dio.getUri(uri);
    return response.data;
  });
  controller!.addYamlRules(ruleFile.readAsStringSync());
  return controller!;
}

Dio? dio;
Dio getDio() {
  if (dio != null) return dio!;
  final Map<String, String> env = Platform.environment;

  final String? httpProxy = EH.noProxy ? null : (EH.proxy ?? env['http_proxy']);
  final Uri? httpProxyUri = httpProxy != null ? Uri.parse(httpProxy) : null;

  final hasProxy = httpProxyUri != null;

// export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

  dio = Dio();
  dio!.interceptors.add(RetryInterceptor(
      dio: dio!,
      logPrint: log.warning,
      retries: 6,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 5),
        Duration(seconds: 30),
        Duration(seconds: 60),
        Duration(seconds: 5 * 60),
      ]));

  dio!.options.headers = {
    'accept-encoding': 'gzip, deflate, br',
    'Accept-Language': 'en-US,en;q=0.5',
    'cache-control': 'max-age=0',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'sec-ch-ua':
        '" Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.55 Safari/537.36'
  };

  final hosts = {'e-hentai.org': '37.48.89.16'};

  final domainFronting = DomainFronting(
    dnsLookup: (host) => hosts[host],
  );

  (dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    if (httpProxyUri != null) {
      client.findProxy = (url) {
        return 'PROXY ${httpProxyUri.host}:${httpProxyUri.port}';
      };
    }
    // 代理开启
    if (hasProxy || EH.domainFronting) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    }
  };

  final cookieJar = CookieJar();

  final cookieList = <Cookie>[Cookie('sl', 'dm_2')];
  if (EH.cookie != null) {
    cookieList.addAll(EH.cookie!
        .split(';')
        .map((e) => e.trim().split('='))
        .where((element) => element.length >= 2)
        .map((e) => Cookie(e[0].trim(), e[1].trim())));
  }
  log.debug(cookieList);
  cookieJar.saveFromResponse(Uri.parse('https://e-hentai.org/'), cookieList);
  cookieJar.saveFromResponse(Uri.parse('https://exhentai.org/'), cookieList);
  dio!.interceptors.add(CookieManager(cookieJar));
  // dio!.interceptors.add(dioLoggerInterceptor);
  domainFronting.bind(dio!);
  domainFronting.enable = EH.domainFronting;
  return dio!;
}

final dioLoggerInterceptor =
    InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
  String headers = "";
  options.headers.forEach((key, value) {
    headers += "| $key: $value";
  });

  print(
      "┌------------------------------------------------------------------------------");
  print('''| [DIO] Request: ${options.method} ${options.uri}
| ${options.data.toString()}
| Headers:\n$headers''');
  print(
      "├------------------------------------------------------------------------------");
  handler.next(options); //continue
}, onResponse: (Response response, handler) async {
  print(
      "| [DIO] Response [code ${response.statusCode}]: ${response.data.toString()}");
  print(
      "└------------------------------------------------------------------------------");
  handler.next(response);
  // return response; // continue
}, onError: (DioError error, handler) async {
  print("| [DIO] Error: ${error.error}: ${error.response?.toString()}");
  print(
      "└------------------------------------------------------------------------------");
  handler.next(error); //continue
});
