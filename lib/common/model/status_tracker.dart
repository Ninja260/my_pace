import 'package:json_annotation/json_annotation.dart';
import 'package:my_pace/common/enums/status.dart';
import 'package:my_pace/common/status_tracker.dart';

part 'status_tracker.g.dart';

@JsonSerializable()
class StatusTracker {
  final Status status;

  final DateTime? startTime;

  final List<StatusLog> statusLogs;

  final int restCount;

  final DateTime? scheduledTime;

  StatusTracker({
    required this.status,
    required this.startTime,
    required this.statusLogs,
    required this.restCount,
    required this.scheduledTime,
  });

  factory StatusTracker.fromJson(Map<String, dynamic> json) =>
      _$StatusTrackerFromJson(json);

  Map<String, dynamic> toJson() => _$StatusTrackerToJson(this);
}

