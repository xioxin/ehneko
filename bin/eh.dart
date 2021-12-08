import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:eh/eh.dart';
import 'package:eh/log.dart';
import 'package:eh/parser.dart';
import 'package:eh/range.dart';
import 'package:queue/queue.dart';
import 'package:scraper/scraper.dart';
import 'package:path/path.dart' as p;

import 'package:dio_domain_fronting/dio_domain_fronting.dart';
import 'package:loggy/loggy.dart';

void main(List<String> arguments) async {
  Loggy.initLoggy(logPrinter: MyPrettyPrinter());
  log.info('Application Launching. arguments: $arguments');
  final runner = CommandRunner("eh", "用于下载EHentai漫画的工具")
    ..addCommand(BatchCommand())
    ..addCommand(GalleryCommand())
    ..addCommand(FixCommand())
    ..run(arguments);
}

addCommonCommand(ArgParser argParser) {
  argParser.addOption('output',
      abbr: 'o', help: '输出目录<!!WIP!!>', valueHelp: "./output");
  argParser.addOption('cookie', abbr: 'c', help: 'Cookie凭证');
  argParser.addFlag('domain-fronting',
      abbr: 'D', negatable: false, help: '开启域名前置');
  argParser.addFlag('force', negatable: false, abbr: 'f', help: '覆盖已有数据');
  argParser.addFlag('no-proxy', negatable: false, abbr: 'P', help: '禁用代理');
  argParser.addOption('proxy',
      valueHelp: '172.0.0.1:8080', help: '代理链接，默认使用环境变量的HTTP_PROXY');
}

class BatchCommand extends Command {
  final name = "batch";
  final description = "批量采集";

  BatchCommand() {
    argParser.addOption('link', abbr: 'l', help: '提供一个搜索页面地址', mandatory: true);
    argParser.addOption('pages',
        abbr: 'p', help: '页码范围(!!WIP!!)', valueHelp: '0:9');
    argParser.addOption('parallel', abbr: 'm', help: '并行数量', valueHelp: '1');
    argParser.addOption('delay',
        abbr: 'd', help: '任务开始时间不低于这个时间(ms)', valueHelp: '1000');
    argParser.addOption('range',
        abbr: 'r',
        help:
            '图片下载范围 \n    <5> 第5个\n    <3:6> 3至6包含3和6 \n    <:4> 前5个 \n    <-4:> 后5个 \n    <:> 全部 \n    多条规则之间使用<,>',
        valueHelp: '0:4,-4:');
    addCommonCommand(argParser);
  }

  @override
  void run() {
    EH.parallel = int.tryParse(argResults!['parallel'] ?? '');
    EH.delay = int.tryParse(argResults!['delay'] ?? '');
    EH.noProxy = argResults!['no-proxy'];
    EH.proxy = argResults!['proxy'];
    EH.domainFronting = argResults!['domain-fronting'];
    EH.cookie = argResults!['cookie'];
    EH.imageRange = argResults!['range'];
    EH.force = argResults!['force'] ?? false;
    EH.downloadList(argResults!['link']);
  }
}

class GalleryCommand extends Command {
  final name = "gallery";
  final description = "下载单个画廊";

  GalleryCommand() {
    argParser.addOption('link', abbr: 'l', help: '提供一个画廊地址', mandatory: true);
    argParser.addOption('range',
        abbr: 'r',
        help:
            '图片下载范围 \n    <5> 第5个\n    <3:6> 3至6包含3和6 \n    <:4> 前5个 \n    <-4:> 后5个 \n    <:> 全部 \n    多条规则之间使用<,>',
        valueHelp: '0:4,-4:');
    addCommonCommand(argParser);
  }

  @override
  void run() {
    EH.noProxy = argResults!['no-proxy'];
    EH.proxy = argResults!['proxy'];
    EH.domainFronting = argResults!['domain-fronting'];
    EH.cookie = argResults!['cookie'];
    EH.imageRange = argResults!['range'];
    EH.force = argResults!['force'] ?? false;
    EH.downloadGallery(argResults!['link'], imageRange: EH.imageRange);
  }
}

class FixCommand extends Command {
  final name = "fix";
  final description = "重新下载失败的画廊";

  FixCommand() {
    addCommonCommand(argParser);
  }

  @override
  void run() {
    // todo!
  }
}
