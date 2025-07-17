import 'package:my_pace/common/enums/person_state.dart';
import 'package:my_pace/common/model/state_log.dart';

abstract interface class StatusTrackerInterface {
  int get restCount;

  PersonState get status;

  DateTime? get startTime;

  List<StateLog> get statusLogs;

  DateTime? get scheduledTime;
}
