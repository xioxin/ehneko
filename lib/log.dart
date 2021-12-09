import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:loggy/loggy.dart';

import 'display.dart';

class MyPrettyPrinter extends LoggyPrinter {
  late IOSink logFileHandle;

  MyPrettyPrinter({
    this.showColors,
  }) : super() {
    final logFile = File(p.join(Directory.current.path, 'eh.log'));
    logFileHandle = logFile.openWrite(mode: FileMode.append);
  }

  final bool? showColors;

  bool get _colorize => showColors ?? false;

  static final _levelColors = {
    LogLevel.debug:
        AnsiColor(foregroundColor: AnsiColor.grey(0.5), italic: true),
    LogLevel.info: AnsiColor(foregroundColor: 35),
    LogLevel.warning: AnsiColor(foregroundColor: 214),
    LogLevel.error: AnsiColor(foregroundColor: 196),
  };

  static final _levelPrefixes = {
    LogLevel.debug: '🐛 ',
    LogLevel.info: '😺 ',
    LogLevel.warning: '😈 ',
    LogLevel.error: '🥵 ',
  };

  static const _defaultPrefix = '🤔 ';

  void saveLogFile(LogRecord record) {
    final _time = record.time.toIso8601String().split('T')[1];
    final _callerFrame =
        record.callerFrame == null ? '-' : '(${record.callerFrame?.location})';
    final _logLevel = record.level
        .toString()
        .replaceAll('Level.', '')
        .toUpperCase()
        .padRight(8);
    final _color =
        _colorize ? levelColor(record.level) ?? AnsiColor() : AnsiColor();
    final _prefix = levelPrefix(record.level) ?? _defaultPrefix;
    logFileHandle.writeln(
        '$_prefix$_time $_logLevel ${record.loggerName} $_callerFrame ${record.message}');
    if (record.stackTrace != null) {
      logFileHandle.writeln(record.stackTrace);
    }
  }

  @override
  void onLog(LogRecord record) {
    final _time = record.time.toIso8601String().split('T')[1];
    final _callerFrame =
        record.callerFrame == null ? '-' : '(${record.callerFrame?.location})';
    final _logLevel = record.level
        .toString()
        .replaceAll('Level.', '')
        .toUpperCase()
        .padRight(8);

    final _color =
        _colorize ? levelColor(record.level) ?? AnsiColor() : AnsiColor();
    final _prefix = levelPrefix(record.level) ?? _defaultPrefix;

    Display.log(_color(
        '$_prefix$_time $_logLevel ${record.loggerName} $_callerFrame ${record.message}'));

    if (record.stackTrace != null) {
      Display.log(record.stackTrace.toString());
    }
    try {
      saveLogFile(record);
    } catch (e) {}
  }

  String? levelPrefix(LogLevel level) {
    return _levelPrefixes[level];
  }

  AnsiColor? levelColor(LogLevel level) {
    return _levelColors[level];
  }
}

class GlobalLoggy implements LoggyType {
  @override
  Loggy<GlobalLoggy> get loggy =>
      Loggy<GlobalLoggy>('EhNeko - ${runtimeType.toString()}');
}

Loggy get log => Loggy<GlobalLoggy>('EhNeko');
