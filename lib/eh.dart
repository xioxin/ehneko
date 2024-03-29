import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eh/display.dart';
import 'package:eh/parser.dart';
import 'package:eh/range.dart';
import 'package:path/path.dart' as p;
import 'package:queue/queue.dart';

import 'http.dart';
import 'log.dart';
import 'model/gallery.dart';
import 'model/state.dart';

class DownloadListReturn {
  String? nextLink;
  DownloadListReturn([this.nextLink]);
}

class EH {
  static Directory outputDir =
      Directory(p.join(Directory.current.path, 'output'));

  static String? cookie;
  static bool domainFronting = false;
  static String? proxy;
  static bool noProxy = false;

  static int? parallel;

  static int? delay;

  static String? imageRange;

  static bool force = false;

  static bool lofiImage = false;

  static bool bannedShutdown = false;

  static String? bannedCommand;

  static loadConfig() {}

  static Queue? _queue;
  static Queue get queue {
    _queue ??= Queue(
        parallel: parallel ?? 1,
        delay: delay != null ? Duration(milliseconds: delay!) : null);
    return _queue!;
  }

  static List<EhState> queueStateList = [];

  static downloadGallery(String url, {String? imageRange}) async {
    imageRange ??= ':';
    log.info("[START] $url");
    Uri uri = Uri.parse(url);
    if (uri.pathSegments.length < 3) throw "Unrecognized link address";
    if (uri.pathSegments.first != 'g') throw "Unrecognized link address";
    final gid = int.tryParse(uri.pathSegments[1]);
    if (gid == null) throw "Unrecognized link address";
    final token = uri.pathSegments[2];
    final galleryDir = Directory(p.join(outputDir.path, '$gid-$token'));
    if (!galleryDir.existsSync()) {
      galleryDir.createSync(recursive: true);
    } else {
      if (EH.force) {
        log.info("[$gid/$token] File already exists. Del file !!!");
        galleryDir.deleteSync(recursive: true);
        galleryDir.createSync(recursive: true);
      }
    }
    final stateFile = File(p.join(galleryDir.path, 'state.json'));
    final metaFile = File(p.join(galleryDir.path, 'meta.json'));
    if (stateFile.existsSync()) {
      final stateText = await stateFile.readAsString();
      final state = EhState.fromJson(JsonDecoder().convert(stateText));
      if (state.complete) {
        log.info("[$gid/$token] SKIP, File already exists");
        return;
      }
    }
    final state = EhState(
      gid: gid,
      token: token,
      complete: false,
      error: false,
      range: imageRange,
      stateFile: stateFile,
      link: uri.toString(),
    );
    await state.save();
    queueStateList.add(state);
    Display.flashState();
    final hasFiles = galleryDir
        .listSync()
        .map((e) => p.basename(e.path))
        .where((name) => name.substring(name.length - 4, name.length) != '.tmp')
        .toList();
    try {
      final gallery = GalleryController(gid, token, host: uri.host);
      final data = await gallery.firstData();
      final length = data.length;
      log.info("[$gid/$token] ${data.title}");
      log.info("[$gid/$token] Save Meta Data");
      metaFile.writeAsStringSync(JsonEncoder.withIndent('  ', myEncode)
          .convert(await gallery.getMixData()));
      final indexList = getRange(imageRange, length: length);
      state.title = data.title;
      state.progressLength = indexList.length;
      int n = 0;
      for (int index in indexList) {
        n += 1;
        if (hasFiles
            .where((e) =>
                e.indexOf((index + 1).toString().padLeft(3, '0') + '-') == 0)
            .isNotEmpty) {
          state.progressCurrent = n;
          log.info("[$gid/$token/$index] SKIP, Image exists $n");
          continue;
        }
        final item = await gallery.getImageInfo(index);
        final imageInfo =
            await item.getImageInfo({'eh_gid': gid, 'eh_token': token});

        String? rawFileName = imageInfo.fileName;
        rawFileName ??= '.unknown';

        final fileName =
            '${(index + 1).toString().padLeft(3, '0')}-$rawFileName';
        log.info(
            "[$gid/$token/$index] ($n/${indexList.length}) Download Image ${imageInfo.image} => $fileName");
        await getDio().download(
            imageInfo.image, p.join(galleryDir.path, fileName) + '.tmp',
            onReceiveProgress: (int count, int total) {
          state.imageDownloadTotal = total;
          state.imageDownloadCount = count;
          Display.flashState();
        },
            options: Options(
                extra: {'eh_gid': gid, 'eh_token': token, 'eh_index': index}));
        File(p.join(galleryDir.path, fileName) + '.tmp')
            .renameSync(p.join(galleryDir.path, fileName));
        state.retry = false;
        state.progressCurrent = n;
        state.imageDownloadTotal = 0;
        state.imageDownloadCount = 0;
        Display.flashState();
      }
      state.complete = true;
      EhState.countComplete++;
      await state.save();
      Display.flashState();
      return true;
    } catch (e, stacktrace) {
      log.error("[$gid/$token] $e", e, stacktrace);
      state.error = true;
      EhState.countError++;
      state.errorMsg = e.toString();
      state.stackTrace = stacktrace.toString();
      await state.save();
      return false;
    }
  }

  static downloadList(String url) async {
    int n = 0;
    while (true) {
      n = n + 1;
      final uri = Uri.parse(url);
      EhState.next = uri.queryParameters['next'];
      EhState.nowListUrl = url;
      Display.flashState();
      final status = await downloadListPage(uri);
      if (status.nextLink != null) {
        url = status.nextLink!;
      } else {
        return;
      }
      // EhState.listPageCount = n;
      Display.flashState();
      // 清理任务状态 减少内存占用
      EH.queueStateList = EH.queueStateList
          .where((element) => element.complete == false)
          .toList();
    }
  }

  static Future<DownloadListReturn> downloadListPage(Uri uri) async {
    String? rawData;
    try {
      log.info("[${uri.toString()}] Load list");
      final controller = getScraperController();
      final parser = await controller.loadUri(uri);
      rawData = parser.data;
      final galleryList = GalleryList.fromJson(parser.parse()!);
      EhState.listData = galleryList;
      int n = 0;
      EhState.subListPageTotal = galleryList.items.length;
      EhState.subListPageCount = 0;
      Display.flashState();
      if (galleryList.items.isEmpty) {
        log.error("[${uri.toString()}] Gallery list is empty");
        return DownloadListReturn();
      }
      for (var item in galleryList.items) {
        queue.add(() async {
          await downloadGallery(item.href, imageRange: EH.imageRange);
          n++;
          EhState.subListPageCount = n;
          Display.flashState();
        });
      }
      await queue.onComplete;
      EhState.subListPageTotal = 0;
      EhState.subListPageCount = 0;
      Display.flashState();
      return DownloadListReturn(galleryList.nextLink);
    } catch (e) {
      if (rawData != null) {
        log.debug("RawHtml: $uri\n" + rawData);
      }
      rethrow;
    }
  }
}

class GalleryController {
  int gid;
  String token;
  late String host;

  Map<String, dynamic>? firstRawData;

  GalleryController(this.gid, this.token, {String? host}) {
    this.host = host ?? 'e-hentai.org';
  }
  Map<int, Future<Gallery>> rawPageDataFuture = {};

  Future<Map<String, dynamic>?> getMixData() async {
    return firstRawData;
  }

  Future<Gallery> load([int pageIndex = 0]) async {
    String? rawData = '';
    Uri uri = Uri.parse("https://$host/g/$gid/$token/");
    if (rawPageDataFuture.containsKey(pageIndex)) {
      return rawPageDataFuture[pageIndex]!;
    }
    try {
      final controller = getScraperController();
      if (pageIndex > 0) {
        uri = uri.replace(query: 'p=$pageIndex');
      }
      rawPageDataFuture[pageIndex] = controller
          .loadUri(uri, {"eh_gid": gid, "eh_token": token}).then((parser) {
        rawData = parser.data;
        final data = parser.parse();
        if (pageIndex == 0) firstRawData = data;
        return Gallery.fromJson(data!);
      });
      return await rawPageDataFuture[pageIndex]!;
    } catch (e) {
      if (rawData != null) {
        log.debug("RawHtml: $uri\n" + rawData!);
      }
      rethrow;
    }
  }

  Future<Gallery> firstData() => load(0);

  Future<int> getLength() {
    return firstData().then((value) => value.length);
  }

  Future<int> getPageItemCount() {
    return firstData().then((value) => value.wrapper.length);
  }

  Future<int> pagesCount() {
    return firstData().then((value) => value.pageList.length);
  }

  Future<GalleryItem> getImageInfo(int index) async {
    final pageItemCount = await getPageItemCount();
    if (index < pageItemCount) {
      return (await firstData()).wrapper[index];
    }
    final subPage = index ~/ pageItemCount;
    final subIndex = index - (pageItemCount * subPage);
    final nowData = await load(subPage);
    return (nowData).wrapper[subIndex];
  }
}

extension GalleryItemEx on GalleryItem {
  Future<GalleryImage> getImageInfo(Map<String, dynamic>? extra) async {
    Uri uri = Uri.parse(href);
    String? rawData;
    try {
      final controller = getScraperController();
      if (EH.lofiImage && uri.pathSegments.first == 's') {
        uri = uri.replace(pathSegments: ['lofi', ...uri.pathSegments]);
      }
      return await controller.loadUri(uri, extra).then((parser) {
        rawData = parser.data;
        return GalleryImage.fromJson(parser.parse()!);
      });
    } catch (e) {
      if (rawData != null) {
        log.debug("RawHtml: $uri\n" + rawData!);
      }
      rethrow;
    }
  }
}

dynamic myEncode(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}
