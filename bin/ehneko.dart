import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:eh/display.dart';
import 'package:eh/eh.dart';
import 'package:eh/log.dart';
import 'package:eh/parser.dart';
import 'package:loggy/loggy.dart';

List<String>? runArguments;

void main(List<String> arguments) async {
  runArguments = arguments;
  final runner = CommandRunner("ehneko", "用于下载EHentai漫画的工具")
    ..addCommand(BatchCommand())
    ..addCommand(GalleryCommand())
    ..addCommand(FixCommand())
    ..addCommand(JsonCommand())
    ..run(arguments);
}

addCommonCommand(ArgParser argParser) {
  argParser.addOption('cookie', abbr: 'c', help: 'Cookie凭证');
  argParser.addFlag('domain-fronting',
      abbr: 'd', negatable: false, help: '开启域名前置');
  argParser.addFlag('force', negatable: false, abbr: 'f', help: '覆盖已有数据');
  argParser.addFlag('no-proxy', negatable: false, abbr: 'P', help: '禁用代理');
  argParser.addOption('proxy',
      valueHelp: 'http://172.0.0.1:8080', help: '代理链接，默认使用环境变量的HTTP_PROXY');
  argParser.addOption('banned-command', help: "ip被封禁时执行指令");
  argParser.addFlag('banned-shutdown', negatable: false, help: "ip被封禁时终止程序");
}

loadCommonResults(ArgResults argResults) {
  EH.noProxy = argResults['no-proxy'];
  EH.proxy = argResults['proxy'];
  EH.domainFronting = argResults['domain-fronting'];
  EH.cookie = argResults['cookie'];
  EH.bannedCommand = argResults['banned-command'];
  EH.bannedShutdown = argResults['banned-shutdown'];
}

class BatchCommand extends Command {
  @override
  final name = "batch";
  @override
  final description = "批量采集";

  BatchCommand() {
    argParser.addOption('link', abbr: 'l', help: '提供一个搜索页面地址', mandatory: true);
    argParser.addOption('pages',
        abbr: 'p',
        help:
            '页码范围 \n    <5> 第5个\n    <3:6> 3至6包含3和6 \n    <:4> 前5个 \n    <-4:> 后5个 \n    <:> 全部 \n    多条规则之间使用<,>',
        valueHelp: '0:9');
    argParser.addOption('parallel', abbr: 'm', help: '并行数量', valueHelp: '1');
    argParser.addOption('range',
        abbr: 'r', help: '图片下载范围 (规则与--pages相同)', valueHelp: '0:4,-4:');
    argParser.addFlag('lofi-image',
        negatable: false, help: '图片信息通过lofi加载（强制780x）');
    addCommonCommand(argParser);
  }

  @override
  void run() {
    Loggy.initLoggy(logPrinter: MyPrettyPrinter());
    Display.init();
    log.info("Application Launching. arguments: $runArguments");
    log.info("Start time: ${DateTime.now()}");
    loadCommonResults(argResults!);
    EH.parallel = int.tryParse(argResults!['parallel'] ?? '');
    EH.imageRange = argResults!['range'];
    EH.force = argResults!['force'] ?? false;
    EH.lofiImage = argResults!['lofi-image'] ?? false;

    EH.downloadList(argResults!['link'], range: argResults!['pages']);
  }
}

class GalleryCommand extends Command {
  @override
  final name = "gallery";
  @override
  final description = "下载单个画廊";

  GalleryCommand() {
    argParser.addOption('link', abbr: 'l', help: '提供一个画廊地址', mandatory: true);
    argParser.addOption('range',
        abbr: 'r',
        help:
            '图片下载范围 \n    <5> 第5个\n    <3:6> 3至6包含3和6 \n    <:4> 前5个 \n    <-4:> 后5个 \n    <:> 全部 \n    多条规则之间使用<,>',
        valueHelp: '0:4,-4:');
    argParser.addFlag('lofi-image',
        negatable: false, help: '图片信息通过lofi加载（强制780x）');
    addCommonCommand(argParser);
  }

  @override
  void run() {
    Loggy.initLoggy(logPrinter: MyPrettyPrinter());
    Display.init();
    log.info("Application Launching. arguments: $runArguments");
    log.info("Start time: ${DateTime.now()}");
    loadCommonResults(argResults!);
    EH.imageRange = argResults!['range'];
    EH.lofiImage = argResults!['lofi-image'] ?? false;
    EH.downloadGallery(argResults!['link'], imageRange: EH.imageRange);
  }
}

class FixCommand extends Command {
  @override
  final name = "fix";
  @override
  final description = "重新下载失败的画廊";

  FixCommand() {
    addCommonCommand(argParser);
  }

  @override
  void run() {
    // todo!
  }
}

class JsonCommand extends Command {
  @override
  final name = "json";
  @override
  final description = "解析数据并以json输出";

  JsonCommand() {
    argParser.addOption('link', abbr: 'l', help: '提供一个地址', mandatory: true);
    addCommonCommand(argParser);
  }

  @override
  void run() async {
    try {
      loadCommonResults(argResults!);
      final uri = Uri.parse(argResults!['link']);
      final controller = getScraperController();
      final parser = await controller.loadUri(uri);
      print(JsonEncoder.withIndent('  ', myEncode).convert(parser.parse()));
    } catch (e) {
      print(JsonEncoder().convert({"error": e.toString()}));
    }
  }
}
