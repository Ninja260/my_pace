// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
      state: $enumDecode(_$PersonStateEnumMap, json['state']),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      stateLogs: (json['stateLogs'] as List<dynamic>)
          .map((e) => StateLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      restCount: (json['restCount'] as num).toInt(),
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
    );

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'state': _$PersonStateEnumMap[instance.state]!,
      'startTime': instance.startTime?.toIso8601String(),
      'stateLogs': instance.stateLogs,
      'restCount': instance.restCount,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
    };

const _$PersonStateEnumMap = {
  PersonState.needStart: 'needStart',
  PersonState.coding: 'coding',
  PersonState.shortBreak: 'shortBreak',
  PersonState.longBreak: 'longBreak',
};
