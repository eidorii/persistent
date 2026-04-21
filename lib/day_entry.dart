import 'dart:ui';

class Routine {
  final String name;
  final Color color;
  const Routine({required this.name, required this.color});
}

class DayEntry {
  final DateTime date;
  final List<Routine> routines;

  DayEntry({required this.date, this.routines = const []});
}