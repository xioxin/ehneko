import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eh/parser.dart';
import 'package:eh/range.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart' as p;
import 'package:queue/queue.dart';

import 'log.dart';
import 'model/gallery.dart';
import 'model/state.dart';

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

  static loadConfig() {}

  static Queue? _queue;
  static Queue get queue {
    _queue ??= Queue(
        parallel: parallel ?? 1,
        delay: delay != null ? Duration(milliseconds: delay!) : null);
    return _queue!;
  }

  static downloadGallery(String url, {String? imageRange}) async {
    imageRange ??= ':';
    log.info("[START] $url");
    final uri = Uri.parse(url);
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
        log.info("[$gid/$token] File already exists. Delete file !!!");
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
        range: imageRange);
    await stateFile.writeAsString(JsonEncoder.withIndent('  ').convert(state));

    try {
      final gallery = GalleryController(gid, token, host: uri.host);
      final data = await gallery.firstData();
      final length = data.length;
      log.info("[$gid/$token] ${data.title}");
      final indexList = getRange(imageRange, length: length);
      int n = 1;
      for (int index in indexList) {
        final item = await gallery.getImageInfo(index);
        final imageInfo = await item.getImageInfo();
        final fileName =
            '${imageInfo.currentPage.toString().padLeft(3, '0')}-${imageInfo.fileName}';
        log.info(
            "[$gid/$token/$index] (${n++}/${indexList.length}) Download Image ${imageInfo.image} => $fileName");
        await getDio()
            .download(imageInfo.image, p.join(galleryDir.path, fileName));
      }
      log.info("[$gid/$token] Save Meta Data");
      metaFile.writeAsStringSync(JsonEncoder.withIndent('  ', myEncode)
          .convert(await gallery.getMixData()));

      final state = EhState(
          gid: gid,
          token: token,
          complete: true,
          error: false,
          range: imageRange);
      await stateFile
          .writeAsString(JsonEncoder.withIndent('  ').convert(state));
    } catch (e, stacktrace) {
      log.error("[$gid/$token] $e", e, stacktrace);
      final state = EhState(
          gid: gid,
          token: token,
          complete: false,
          error: true,
          errorMsg: e.toString(),
          range: imageRange,
          stackTrace: stacktrace.toString());
      await stateFile
          .writeAsString(JsonEncoder.withIndent('  ').convert(state));
    }
  }

  static downloadList(String url, {String? range}) async {
    final uri = Uri.parse(url);

    final controller = getScraperController();
    final parser = await controller.loadUri(uri);
    final galleryList = GalleryList.fromJson(parser.parse()!);
    if (galleryList.items.isEmpty) {
      log.info("[$url] GalleryListIsEmpty");
    }
    for (var item in galleryList.items) {
      queue.add(() async {
        await downloadGallery(item.href, imageRange: EH.imageRange);
      });
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

  Future<Gallery> load([int pageIndex = 0]) {
    final controller = getScraperController();
    if (rawPageDataFuture.containsKey(pageIndex)) {
      return rawPageDataFuture[pageIndex]!;
    }
    Uri uri = Uri.parse("https://$host/g/$gid/$token/");
    if (pageIndex > 0) {
      uri = uri.replace(query: 'p=$pageIndex');
    }
    rawPageDataFuture[pageIndex] = controller.loadUri(uri).then((parser) {
      final data = parser.parse();
      if (pageIndex == 0) firstRawData = data;
      return Gallery.fromJson(data!);
    });
    return rawPageDataFuture[pageIndex]!;
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
  Future<GalleryImage> getImageInfo() async {
    final controller = getScraperController();
    return controller
        .loadUri(Uri.parse(href))
        .then((parser) => GalleryImage.fromJson(parser.parse()!));
  }
}

dynamic myEncode(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}
