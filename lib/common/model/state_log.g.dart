// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateLog _$StateLogFromJson(Map<String, dynamic> json) => StateLog(
      state: $enumDecode(_$PersonStateEnumMap, json['state']),
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$StateLogToJson(StateLog instance) => <String, dynamic>{
      'state': _$PersonStateEnumMap[instance.state]!,
      'time': instance.time.toIso8601String(),
    };

const _$PersonStateEnumMap = {
  PersonState.needStart: 'needStart',
  PersonState.coding: 'coding',
  PersonState.shortBreak: 'shortBreak',
  PersonState.longBreak: 'longBreak',
};
