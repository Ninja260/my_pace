import 'package:flutter/material.dart';
import 'package:my_pace/common/interfaces/status_tracker.interface.dart';

abstract interface class StatusTrackerForServiceInterface
    implements StatusTrackerInterface, ChangeNotifier {
  void start();

  void stop();
}
