import 'dart:async';
import 'dart:math';

import 'package:eh/eh.dart';
import 'dart:io';

import 'model/state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:characters/characters.dart';

import './log.dart' as G;

class Display {
  // static String buffer = '';
  // static print(String s) => buffer += s;
  static String x1b = "\x1b";
  static up(int l) => stdout.write("$x1b[${l}A");
  static down(int l) => stdout.write("$x1b[${l}B");
  static left(int l) => stdout.write("$x1b[${l}D");
  static right(int l) => stdout.write("$x1b[${l}C");
  static clearLine() => stdout.write("$x1b[2J");
  // static clearScreen() => print("$x1b[2J");
  static clearToEnd() => stdout.write("$x1b[J");
  static clearColor() => stdout.write("$x1b[0m");

  static insertLine() => stdout.write("$x1b[\xff\x4c");

  static int height = 10;
  static int barLeftWidth = 20;
  static int barWidth = 40;

  static init() {
    print('\n'.repeat(20));
    G.log.info(" ");
    G.log.info("       ＿＿");
    G.log.info("     ／＞  フ");
    G.log.info("     |   _  _ l");
    G.log.info("     ／` ミ＿xノ");
    G.log.info("     /      |");
    G.log.info("    /  ヽ   ﾉ");
    G.log.info("    │  | | |");
    G.log.info(" ／￣|   | | |");
    G.log.info(" | (￣ヽ＿_ヽ_)__)");
    G.log.info(" ＼二つ");
    G.log.info(" ");
    flashStateSubject.sampleTime(Duration(milliseconds: 100)).listen((value) {
      log();
    });
  }

  static String bar(EhState state) {
    String leftText = "${state.gid}/${state.token}";
    String rightText = "";
    final precent = state.progressLength == 0
        ? 0
        : state.progressCurrent / state.progressLength;
    final arrowNumber = (barWidth * precent).round();
    double subPrecent = 0;
    int subArrowNumber = 0;
    double imagePrecent = 0;
    if (state.progressCurrent < state.progressLength) {
      subPrecent = 1 / state.progressLength;
      if (state.imageDownloadTotal != 0) {
        imagePrecent = state.imageDownloadCount / state.imageDownloadTotal;
      }
      subArrowNumber = (barWidth * subPrecent * imagePrecent).round();
    }
    final bar = '#'.repeat(arrowNumber) +
        '='.repeat(subArrowNumber) +
        ' '.repeat(barWidth - arrowNumber - subArrowNumber);
    leftText = leftText.padLeft(barLeftWidth);
    String color = '\x1b[0m';
    if (state.error) {
      color = '\x1b[41m';
      rightText = state.errorMsg ?? '';
    } else if (state.complete) {
      color = '\x1b[32m';
    } else if (state.retry) {
      color = '\x1b[33m';
      rightText = "Retry ${state.retryAttempt}: ${state.errorMsg ?? ''}";
    }
    if (rightText == '' && state.title != null) {
      rightText = state.title!;
    }

    rightText = rightText.textOverflowEllipsis(50);

    final pText =
        "${((precent + imagePrecent * subPrecent) * 100).floor().toString().padLeft(3)}%";
    return "$color$leftText [$bar] $pText\x1b[0m $rightText";
  }

  static List<String> stateStringList() {
    List<EhState> queueStateList = [];
    final runState = EH.queueStateList
        .where((element) => element.complete == false && element.error == false)
        .toList();
    final notRunState = EH.queueStateList.reversed
        .where((element) => element.complete == true || element.error == true)
        .toList();
    queueStateList = [
      ...runState.reversed,
      ...notRunState.reversed,
    ].take(height).toList().reversed.toList();
    return queueStateList.map((e) => bar(e)).toList();
  }

  static String batchStateString() {
    if (EhState.nowListUrl == null) return "";
    return "🐱 [${EhState.listPageCount}/${EhState.listPageTotal}] (${EhState.subListPageCount}/${EhState.subListPageTotal})"
        " ${EhState.nowListUrl} "
        " \x1b[32mComplete:${EhState.countComplete}\x1b[0m  \x1b[31mError:${EhState.countError}\x1b[0m";
  }

  static log([String? text]) {
    up(height + 1);
    left(1000);
    clearToEnd();
    if (text != null) print(text);
    print(batchStateString());
    final stateList = stateStringList();
    for (var text in stateList) {
      print(text);
    }
    List.generate((height) - stateList.length, (index) => {print("")});
  }

  static BehaviorSubject flashStateSubject = BehaviorSubject();
  static flashState() {
    flashStateSubject.add(null);
  }
}

extension RepeatString on String {
  repeat(int count) => List.generate(count, (index) => this).join('');
  String textOverflowEllipsis(int limit) {
    if (characters.length > limit) {
      return '${characters.take(limit - 1)}…';
    } else {
      return this;
    }
  }
}
