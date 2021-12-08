import 'package:json_annotation/json_annotation.dart';
part 'state.g.dart';

@JsonSerializable()
class EhState extends Object {
  int gid;
  String token;
  bool complete;
  bool error;
  String? errorMsg;
  String? stackTrace;
  String? range;

  EhState({
    required this.gid,
    required this.token,
    this.complete = false,
    this.error = false,
    this.errorMsg,
    this.stackTrace,
    this.range,
  });

  factory EhState.fromJson(Map<String, dynamic> srcJson) =>
      _$EhStateFromJson(srcJson);

  Map<String, dynamic> toJson() => _$EhStateToJson(this);
}
