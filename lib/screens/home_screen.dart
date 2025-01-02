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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pace'),
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

              return IconButton(
                onPressed: isRunning
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/setting');
                      },
                icon: const Icon(Icons.settings),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/log');
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: FlutterBackgroundService().on('update'),
          builder: (context, snapshot) {
            String text = Status.needStart.longText;
            Status status = Status.needStart;

            if (snapshot.hasData) {
              final data = snapshot.data!;
              final statusTracker = StatusTracker.fromJson(data['data']);
              text = statusTracker.status.longText;
              status = statusTracker.status;
            }

            String buttonText = "";

            if (status == Status.needStart) {
              buttonText = 'START';
            } else {
              buttonText = 'STOP';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    isRunning
                        ? service.invoke("stopService")
                        : service.startService();
                  },
                  child: Text(
                    buttonText,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
