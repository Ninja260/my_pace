// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_tracker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusTracker _$StatusTrackerFromJson(Map<String, dynamic> json) =>
    StatusTracker(
      status: $enumDecode(_$StatusEnumMap, json['status']),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      statusLogs: (json['statusLogs'] as List<dynamic>)
          .map((e) => StatusLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      restCount: (json['restCount'] as num).toInt(),
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
    );

Map<String, dynamic> _$StatusTrackerToJson(StatusTracker instance) =>
    <String, dynamic>{
      'status': _$StatusEnumMap[instance.status]!,
      'startTime': instance.startTime?.toIso8601String(),
      'statusLogs': instance.statusLogs,
      'restCount': instance.restCount,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
    };

const _$StatusEnumMap = {
  Status.needStart: 'needStart',
  Status.coding: 'coding',
  Status.shortBreak: 'shortBreak',
  Status.longBreak: 'longBreak',
};
