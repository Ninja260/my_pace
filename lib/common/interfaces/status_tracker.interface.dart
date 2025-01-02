import 'package:my_pace/common/enums/status.dart';
import 'package:my_pace/common/status_tracker.dart';

abstract interface class StatusTrackerInterface {
  int get restCount;

  Status get status;

  DateTime? get startTime;

  List<StatusLog> get statusLogs;
}