import 'package:flutter/material.dart';
import 'package:persistent/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Persistent',
        home: const CalendarPage()
    );
  }
}
