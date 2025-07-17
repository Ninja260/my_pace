import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:my_pace/common/enums/status.dart';
import 'package:my_pace/common/model/status_tracker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterBackgroundService().invoke('fetchUpdate');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        // title: const Text('My Pace'),
        actions: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: FlutterBackgroundService().on('update'),
            builder: (context, snapshot) {
              bool isRunning = false;

              if (snapshot.hasData) {
                final data = snapshot.data!;
                final statusTracker = StatusTracker.fromJson(data['data']);
                isRunning = statusTracker.status != Status.needStart;
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: isRunning
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/setting');
                          },
                    icon: const Icon(Icons.settings),
                  ),
                  if (isRunning)
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/log');
                      },
                      icon: const Icon(Icons.history),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on('update'),
                builder: (context, snapshot) {
                  String text = Status.needStart.longText;
                  Status status = Status.needStart;
                  DateTime? scheduledTime;
                  bool isRunning = false;

                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final statusTracker = StatusTracker.fromJson(data['data']);
                    text = statusTracker.status.longText;
                    status = statusTracker.status;
                    scheduledTime = statusTracker.scheduledTime;
                    isRunning = statusTracker.status != Status.needStart;
                  }

                  late IconData buttonIcon;

                  if (status == Status.needStart) {
                    buttonIcon = Icons.play_arrow;
                  } else {
                    buttonIcon = Icons.pause;
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRunning) ...[
                        RemainingTimeWidget(
                          scheduledTime: scheduledTime,
                        ),
                        SizedBox(
                          height: textTheme.bodyLarge?.fontSize,
                        ),
                        Text(
                          text,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(
                          height: textTheme.titleLarge?.fontSize,
                        ),
                      ],
                      if (!isRunning) ...[
                        Text(
                          text,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(
                          height: textTheme.titleLarge?.fontSize,
                        ),
                      ],
                      FloatingActionButton(
                        onPressed: () async {
                          final service = FlutterBackgroundService();
                          var isRunning = await service.isRunning();
                          isRunning
                              ? service.invoke("stopService")
                              : service.startService();
                        },
                        backgroundColor: colorScheme.tertiaryContainer,
                        shape: const CircleBorder(),
                        child: Icon(
                          buttonIcon,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: kToolbarHeight,
          ),
        ],
      ),
    );
  }
}

class RemainingTimeWidget extends StatefulWidget {
  const RemainingTimeWidget({
    super.key,
    required this.scheduledTime,
  });

  final DateTime? scheduledTime;

  @override
  State<RemainingTimeWidget> createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends State<RemainingTimeWidget> {
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant RemainingTimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scheduledTime != oldWidget.scheduledTime) {
      _stopTimer();
      _startTimer();
    }
  }

  void _startTimer() {
    if (widget.scheduledTime == null) {
      setState(() {
        _remainingTime = Duration.zero;
      });
      return;
    }

    setState(() {
      _remainingTime = widget.scheduledTime!.difference(DateTime.now());
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _stopTimer();
        return;
      }
      setState(() {
        _remainingTime = widget.scheduledTime!.difference(DateTime.now());
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      _formatDuration(_remainingTime),
      style: textTheme.titleLarge?.copyWith(
        color: colorScheme.onPrimary,
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
