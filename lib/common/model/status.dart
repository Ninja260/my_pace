import 'package:json_annotation/json_annotation.dart';
import 'package:my_pace/common/enums/person_state.dart';
import 'package:my_pace/common/model/state_log.dart';

part 'status.g.dart';

@JsonSerializable()
class Status {
  final PersonState state;

  final DateTime? startTime;

  final List<StateLog> stateLogs;

  final int restCount;

  final DateTime? scheduledTime;

  Status({
    required this.state,
    required this.startTime,
    required this.stateLogs,
    required this.restCount,
    required this.scheduledTime,
  });

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
