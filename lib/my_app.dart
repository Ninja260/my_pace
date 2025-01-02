import 'package:flutter/material.dart';
import 'package:my_pace/screens/home_screen.dart';
import 'package:my_pace/screens/log_screen.dart';
import 'package:my_pace/screens/setting_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/log': (context) => const LogScreen(),
        '/setting': (context) => const SettingScreen(),
      },
    );
  }
}
