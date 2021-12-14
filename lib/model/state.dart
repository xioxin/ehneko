import 'dart:convert';
import 'dart:io';

import 'package:eh/model/gallery.dart';
import 'package:json_annotation/json_annotation.dart';
part 'state.g.dart';

@JsonSerializable()
class EhState extends Object {
  @override
  toString() => "$gid/$token ($progressCurrent/$progressLength)";

  static String? nowListUrl;
  static int? nowListPage;
  static int listPageCount = 0;
  static int listPageTotal = 0;

  static int subListPageCount = 0;
  static int subListPageTotal = 0;

  static GalleryList? listData;

  static int countComplete = 0;
  static int countError = 0;

  static bool cooling = false;
  static DateTime? coolDownTime;

  int gid;
  String token;
  bool complete;
  bool error;
  String? errorMsg;
  String? stackTrace;
  String? range;
  String? link;

  @JsonKey(ignore: true)
  File? stateFile;

  @JsonKey(ignore: true)
  bool retry;

  @JsonKey(ignore: true)
  String? title;

  @JsonKey(ignore: true)
  int retryAttempt = 0;

  @JsonKey(ignore: true)
  int progressCurrent = 0;

  @JsonKey(ignore: true)
  int progressLength = 0;

  @JsonKey(ignore: true)
  int imageDownloadCount = 0;

  @JsonKey(ignore: true)
  int imageDownloadTotal = 0;

  EhState({
    required this.gid,
    required this.token,
    this.complete = false,
    this.error = false,
    this.retry = false,
    this.errorMsg,
    this.stackTrace,
    this.range,
    this.stateFile,
    this.link,
  });

  save() async {
    return await stateFile
        ?.writeAsString(JsonEncoder.withIndent('  ').convert(toJson()));
  }

  factory EhState.fromJson(Map<String, dynamic> srcJson) =>
      _$EhStateFromJson(srcJson);

  Map<String, dynamic> toJson() => _$EhStateToJson(this);
}
