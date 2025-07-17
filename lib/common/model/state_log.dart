import 'package:json_annotation/json_annotation.dart';
import 'package:my_pace/common/enums/person_state.dart';

part 'state_log.g.dart';

@JsonSerializable()
class StateLog {
  final PersonState state;
  final DateTime time;

  StateLog({
    required this.state,
    required this.time,
  });

  factory StateLog.fromJson(Map<String, dynamic> json) =>
      _$StateLogFromJson(json);

  Map<String, dynamic> toJson() => _$StateLogToJson(this);
}
