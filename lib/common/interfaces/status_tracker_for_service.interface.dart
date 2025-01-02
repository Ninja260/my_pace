import 'package:my_pace/common/interfaces/status_tracker.interface.dart';

abstract interface class StatusTrackerForServiceInterface implements StatusTrackerInterface{
  void start();

  void stop();
}