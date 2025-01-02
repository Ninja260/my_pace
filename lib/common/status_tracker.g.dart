// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_tracker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusLog _$StatusLogFromJson(Map<String, dynamic> json) => StatusLog(
      status: $enumDecode(_$StatusEnumMap, json['status']),
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$StatusLogToJson(StatusLog instance) => <String, dynamic>{
      'status': _$StatusEnumMap[instance.status]!,
      'time': instance.time.toIso8601String(),
    };

const _$StatusEnumMap = {
  Status.needStart: 'needStart',
  Status.coding: 'coding',
  Status.shortBreak: 'shortBreak',
  Status.longBreak: 'longBreak',
};
