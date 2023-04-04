// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EhState _$EhStateFromJson(Map<String, dynamic> json) => EhState(
      gid: json['gid'] as int,
      token: json['token'] as String,
      complete: json['complete'] as bool? ?? false,
      error: json['error'] as bool? ?? false,
      errorMsg: json['errorMsg'] as String?,
      stackTrace: json['stackTrace'] as String?,
      range: json['range'] as String?,
      link: json['link'] as String?,
    );

Map<String, dynamic> _$EhStateToJson(EhState instance) => <String, dynamic>{
      'gid': instance.gid,
      'token': instance.token,
      'complete': instance.complete,
      'error': instance.error,
      'errorMsg': instance.errorMsg,
      'stackTrace': instance.stackTrace,
      'range': instance.range,
      'link': instance.link,
    };
