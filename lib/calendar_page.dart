import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime startDate = DateTime(2026, 1, 1);
  final int numberOfWeeks = 52;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildCalendarGrid(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: numberOfWeeks,
      itemBuilder: (context, weekIndex) {
        return _buildWeekColumn(weekIndex);
      },
    );
  }

  Widget _buildWeekColumn(int weekIndex) {
    DateTime weekStart = startDate.add(Duration(days: weekIndex * 7));
    DateTime monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (dayIndex) {
          DateTime currentDate = monday.add(Duration(days: dayIndex));
          return _buildDayCell(currentDate);
        }),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    bool isCurrentMonth = date.month == 1;
    bool isWeekday = date.weekday < 6;
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? (isWeekday
                  ? Colors.grey[300]
                  : Color.fromRGBO(241, 164, 164, 1.0))
            : (isWeekday
                  ? Colors.grey[200]
                  : Color.fromRGBO(248, 203, 203, 1.0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isCurrentMonth ? Colors.black87 : Colors.black26,
          ),
        ),
      ),
    );
  }
}
