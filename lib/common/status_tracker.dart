import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:my_pace/common/enums/person_state.dart';
import 'package:my_pace/common/interfaces/status_tracker_for_service.interface.dart';
import 'package:my_pace/common/model/state_log.dart';
import 'package:my_pace/stores/setting.dart';
import 'package:permission_handler/permission_handler.dart';

class StatusTrackerUsesTimer extends ChangeNotifier
    implements StatusTrackerForServiceInterface {
  AudioPlayer? _audioPlayer;

  final List<StateLog> _statusLogs = [];

  int _restCount = 0;

  Timer? _timer;

  DateTime? _scheduledTime;

  @override
  int get restCount => _restCount;

  @override
  DateTime? get scheduledTime => _scheduledTime;

  @override
  PersonState get status =>
      _statusLogs.isNotEmpty ? _statusLogs.last.state : PersonState.needStart;

  @override
  DateTime? get startTime =>
      _statusLogs.isNotEmpty ? _statusLogs.first.time : null;

  @override
  List<StateLog> get statusLogs => _statusLogs;

  @override
  void start() {
    _initAudioPlayer();
    _startCoding();
  }

  @override
  void stop() {
    _clear();
    _audioPlayer?.stop();
    _timer?.cancel();
  }

  Future<void> _startCoding() async {
    int codingDuration = await Setting.getCodingDuration();
    DateTime restTime = DateTime.now().add(Duration(minutes: codingDuration));

    _scheduledTime = restTime;
    _setStatus(PersonState.coding);
    _audioPlayer?.stop();

    _schedule(
      time: restTime,
      function: _startRest,
    );
  }

  void _startRest() async {
    int longBreakFrequency = await Setting.getShortBreaksBeforeLongBreak() + 1;
    int currentRestCount = restCount + 1;
    PersonState status = currentRestCount % longBreakFrequency == 0
        ? PersonState.longBreak
        : PersonState.shortBreak;

    int breakDuration = status == PersonState.shortBreak
        ? await Setting.getShortBreakDuration()
        : await Setting.getLongBreakDuration();
    DateTime codingTime = DateTime.now().add(Duration(minutes: breakDuration));

    _scheduledTime = codingTime;
    _setStatus(status);

    _audioPlayer?.resume();

    _schedule(
      time: codingTime,
      function: _startCoding,
    );
  }

  void _schedule({
    required DateTime time,
    required void Function() function,
  }) {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!DateTime.now().isBefore(time)) {
        timer.cancel();
        function();
      }
    });
  }

  void _initAudioPlayer() {
    if (_audioPlayer != null) {
      return;
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer!.setReleaseMode(ReleaseMode.loop);
    _audioPlayer!
        .setSource(AssetSource('music/relaxing-piano-music-272714.mp3'));
  }

  void _setStatus(PersonState status) {
    if (status == PersonState.needStart) {
      _clear();
      return;
    }

    _statusLogs.add(
      StateLog(
        state: status,
        time: DateTime.now(),
      ),
    );

    switch (status) {
      case PersonState.shortBreak:
      case PersonState.longBreak:
        _restCount++;
        break;
      default:
        break;
    }

    notifyListeners();
  }

  void _clear() {
    _statusLogs.clear();
    _restCount = 0;

    notifyListeners();
  }
}

const String isolateName = 'serviceIsolate';

ReceivePort receivePort = ReceivePort();

void _registerSendPortInIsolateNameServer() {
  IsolateNameServer.removePortNameMapping(isolateName);
  IsolateNameServer.registerPortWithName(
    receivePort.sendPort,
    isolateName,
  );
}

class StatusTrackerUsesAlarmManager extends ChangeNotifier
    implements StatusTrackerForServiceInterface {
  StatusTrackerUsesAlarmManager() {
    _registerSendPortInIsolateNameServer();
    _streamSubscription = receivePort.listen((message) {
      if (message == 'coding') {
        _startCoding();
      } else if (message == 'break') {
        _startRest();
      }
    });
  }

  StreamSubscription? _streamSubscription;

  AudioPlayer? _audioPlayer;

  final List<StateLog> _statusLogs = [];

  int _restCount = 0;

  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.denied;

  DateTime? _scheduledTime;

  @override
  int get restCount => _restCount;

  @override
  DateTime? get scheduledTime => _scheduledTime;

  @override
  PersonState get status =>
      _statusLogs.isNotEmpty ? _statusLogs.last.state : PersonState.needStart;

  @override
  DateTime? get startTime =>
      _statusLogs.isNotEmpty ? _statusLogs.first.time : null;

  @override
  List<StateLog> get statusLogs => _statusLogs;

  @override
  void start() {
    Permission.scheduleExactAlarm.status.then((status) {
      _exactAlarmPermissionStatus = status;

      if (_exactAlarmPermissionStatus == PermissionStatus.granted) {
        _initAudioPlayer();
        _startCoding();
      } else {
        Permission.scheduleExactAlarm
            .onGrantedCallback(
                () => _exactAlarmPermissionStatus = PermissionStatus.granted)
            .request();
      }
    });
  }

  @override
  void stop() {
    _clear();
    _audioPlayer?.stop();
    _cancelAlarms();
    _streamSubscription?.cancel();
    receivePort.close();
  }

  Future<void> _startCoding() async {
    int codingDuration = await Setting.getCodingDuration();
    DateTime restTime = DateTime.now().add(Duration(minutes: codingDuration));

    _scheduledTime = restTime;
    _setStatus(PersonState.coding);
    _audioPlayer?.stop();

    _schedule(
      time: restTime,
      status: 'break',
    );
  }

  void _startRest() async {
    int longBreakFrequency = await Setting.getShortBreaksBeforeLongBreak() + 1;
    int currentRestCount = restCount + 1;
    PersonState status = currentRestCount % longBreakFrequency == 0
        ? PersonState.longBreak
        : PersonState.shortBreak;

    int breakDuration = status == PersonState.shortBreak
        ? await Setting.getShortBreakDuration()
        : await Setting.getLongBreakDuration();
    DateTime codingTime = DateTime.now().add(Duration(minutes: breakDuration));

    _scheduledTime = codingTime;
    _setStatus(status);

    _audioPlayer?.resume();

    _schedule(
      time: codingTime,
      status: 'coding',
    );
  }

  void _schedule({
    required DateTime time,
    required String status,
  }) {
    if (status == 'coding') {
      AndroidAlarmManager.oneShotAt(
        time,
        0,
        triggerCoding,
        allowWhileIdle: true,
        exact: true,
        wakeup: true,
      );
    } else if (status == 'break') {
      AndroidAlarmManager.oneShotAt(
        time,
        1,
        triggerBreak,
        allowWhileIdle: true,
        exact: true,
        wakeup: false,
      );
    }
  }

  @pragma('vm:entry-point')
  static void triggerCoding() {
    SendPort? sendToServicePort =
        IsolateNameServer.lookupPortByName(isolateName);
    sendToServicePort?.send('coding');
  }

  @pragma('vm:entry-point')
  static void triggerBreak() {
    SendPort? sendToServicePort =
        IsolateNameServer.lookupPortByName(isolateName);
    sendToServicePort?.send('break');
  }

  void _initAudioPlayer() {
    if (_audioPlayer != null) {
      return;
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer!.setReleaseMode(ReleaseMode.loop);
    _audioPlayer!
        .setSource(AssetSource('music/relaxing-piano-music-272714.mp3'));
  }

  void _setStatus(PersonState status) {
    if (status == PersonState.needStart) {
      throw '';
    }

    _statusLogs.add(
      StateLog(
        state: status,
        time: DateTime.now(),
      ),
    );

    switch (status) {
      case PersonState.shortBreak:
      case PersonState.longBreak:
        _restCount++;
        break;
      default:
        break;
    }

    notifyListeners();
  }

  void _clear() {
    _statusLogs.clear();
    _restCount = 0;

    notifyListeners();
  }

  void _cancelAlarms() {
    AndroidAlarmManager.cancel(0);
    AndroidAlarmManager.cancel(1);
  }
}
