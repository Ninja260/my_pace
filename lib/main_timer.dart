import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_pace/common/enums/status.dart';
import 'package:my_pace/common/model/status_tracker.dart';
import 'package:my_pace/my_app.dart';
import 'package:my_pace/common/status_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();
  runApp(const MainApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
    playSound: false,
    enableVibration: false,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'My Pace',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StatusTrackerUsesTimer statusTracker = StatusTrackerUsesTimer();

  service.on('stopService').listen((event) {
    statusTracker.stop();
    statusTracker.dispose();
    service.stopSelf();
  });

  service.on('fetchUpdate').listen((event) {
    service.invoke('update', {
      'data': StatusTracker(
        status: statusTracker.status,
        startTime: statusTracker.startTime,
        statusLogs: statusTracker.statusLogs,
        restCount: statusTracker.restCount,
      )
    });
  });

  statusTracker.addListener(() {
    if (service is AndroidServiceInstance) {
      if (statusTracker.status == Status.needStart) {
        flutterLocalNotificationsPlugin.cancel(888);
      } else {
        flutterLocalNotificationsPlugin.show(
          888,
          'My Pace',
          statusTracker.status.longText,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
    service.invoke('update', {
      'data': StatusTracker(
        status: statusTracker.status,
        startTime: statusTracker.startTime,
        statusLogs: statusTracker.statusLogs,
        restCount: statusTracker.restCount,
      ),
    });
  });

  statusTracker.start();
}
