import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pace/my_app.dart';
import 'package:my_pace/service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();
  runApp(const MainApp());
}
