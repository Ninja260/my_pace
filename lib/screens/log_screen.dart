import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:my_pace/common/model/status_tracker.dart';
import 'package:my_pace/common/status_tracker.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterBackgroundService().invoke('fetchUpdate');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FlutterBackgroundService().on('update'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final statusTracker = StatusTracker.fromJson(data['data']);

            List<StatusLog> statusLogs = statusTracker.statusLogs;
            int itemCount = statusLogs.length;

            DateTime? lastDateTime;

            return ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) {
                String escapedMinutes = '';
                if (lastDateTime != null) {
                  escapedMinutes = (statusLogs[index]
                          .time
                          .difference(lastDateTime!)
                          .inMinutes)
                      .toString();
                }
                lastDateTime = statusLogs[index].time;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: statusLogs[index].status.shortText,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            if (escapedMinutes.isNotEmpty)
                              TextSpan(
                                text: '  +$escapedMinutes min',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        statusLogs[index].time.toString().split('.')[0],
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text(
              'No logs yet',
            ),
          );
        },
      ),
    );
  }
}
