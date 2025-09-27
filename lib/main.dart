import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'alarm_provider.dart';         // Your provider managing alarms
import 'notification_service.dart';  // Your notification scheduling service
import 'alarm_list_screen.dart';     // Alarm list UI screen with background image

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanced Alarm Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AlarmListScreen(),  // Stateful screen with background image
    );
  }
}
