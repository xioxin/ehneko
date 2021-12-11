import 'dart:async';
import 'dart:io';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:eh/display.dart';
import 'package:eh/log.dart';
import 'package:dio_domain_fronting/dio_domain_fronting.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:collection/collection.dart';
import 'eh.dart';

Dio? dio;
Dio getDio() {
  if (dio != null) return dio!;
  final Map<String, String> env = Platform.environment;

  final String? httpProxy = EH.noProxy ? null : (EH.proxy ?? env['http_proxy']);
  final Uri? httpProxyUri = httpProxy != null ? Uri.parse(httpProxy) : null;

  final hasProxy = httpProxyUri != null;
  log.debug("httpProxy: $httpProxy");
  log.debug("domainFronting: ${EH.domainFronting}");

  dio = Dio();
  final retryInterceptor = RetryInterceptor(
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
    ],
    retryEvaluator: (DioError error, attempt) async {
      final shouldRetry =
          RetryInterceptor.defaultRetryEvaluator(error, attempt);
      try {
        final gid = error.requestOptions.extra['eh_gid'];
        final token = error.requestOptions.extra['eh_token'];
        final roAttempt = error.requestOptions.extra['ro_attempt'];
        final state = EH.queueStateList.firstWhereOrNull(
            (element) => element.gid == gid && element.token == token);
        if (state != null) {
          state.retry = true;
          state.retryAttempt = roAttempt ?? 0;
          state.errorMsg = error.toString();
          Display.flashState();
        }
      } catch (e, stackTrace) {
        log.error(e.toString(), e, stackTrace);
      }
      return shouldRetry;
    },
  );

  dio!.interceptors.add(retryInterceptor);

  dio!.options.sendTimeout = 1000 * 30;
  dio!.options.connectTimeout = 1000 * 30;
  dio!.options.receiveTimeout = 1000 * 30;
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
  dio!.interceptors.add(
      EhCooler(dio!, shutdown: EH.bannedShutdown, command: EH.bannedCommand));
  domainFronting.enable = EH.domainFronting;
  return dio!;
}

class EhCooler extends Interceptor {
  Dio dio;
  bool shutdown;
  String? command;
  EhCooler(this.dio, {this.shutdown = false, this.command});

  static Future? cooler;

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.data is String) {
      final String body = response.data;
      // "Your IP address has been temporarily banned for excessive pageloads which indicates that you are using automated
      //mirroring/harvesting software. The ban expires in 55 minutes and 47 seconds";
      // expires in 1 days and 20 hours
      final ipBan =
          body.contains("Your IP address has been temporarily banned");
      if (ipBan) {
        log.warning("🤚 Your IP address has been temporarily banned");
        if (shutdown) {
          log.error(body.replaceAll(RegExp('<.+?>'), ''));
          exit(1);
        } else {
          await waitForCooling(body);
        }
        try {
          await dio
              .fetch(response.requestOptions)
              .then((value) => handler.resolve(value));
        } on DioError catch (e) {
          handler.reject(e);
        }
      }
      return;
    }
    handler.next(response);
  }

  waitForCooling(String body) {
    cooler ??= _waitForCooling(body);
    return cooler;
  }
  _waitForCooling(String body) async {
    if (command != null) {
      final commandList = command!.split(' ').toList();
      final executable = commandList.first;
      log.debug('🧊 Run Command: $commandList');
      final ProcessResult result =
          await Process.run(executable, commandList.sublist(1));
      if (result.stdout is String) {
        log.debug('${result.stdout}');
      }
      if (result.stderr is String) {
        log.error('${result.stderr}');
      }
      if (result.exitCode != 0) {
        log.debug('🧊 ExitCode: ${result.exitCode}');
      }
      cooler = null;
    } else {
      final day = RegExp(r'(\d+) days').firstMatch(body)?.group(1) ?? '0';
      final minute = RegExp(r'(\d+) minutes').firstMatch(body)?.group(1) ?? '0';
      final second = RegExp(r'(\d+) seconds').firstMatch(body)?.group(1) ?? '0';
      final delay = Duration(
              days: int.parse(day),
              minutes: int.parse(minute),
              seconds: int.parse(second)) +
          Duration(minutes: 5);
      await Future.delayed(delay);
      cooler = null;
    }
  }

}
