import 'package:flutter/material.dart';

import 'controllers/calorie_tracker_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key, this.controller});

  /// Supplying a controller makes the entire application easy to widget-test.
  final CalorieTrackerController? controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeScreen(controller: controller),
    );
  }
}
