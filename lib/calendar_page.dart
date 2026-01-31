import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime startDate = DateTime(2023, 1, 1); // Start 3 years back
  final int numberOfWeeks = 520; // 10 years of weeks
  final ScrollController _scrollController = ScrollController();
  int _currentMonth = DateTime.now().month; // Track current visible month
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    int weeksSinceStart = now.difference(startDate).inDays ~/ 7;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(weeksSinceStart * 68.0); // 60 + 8 padding
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Calculate which week is currently centered
    double offset = _scrollController.offset;
    int centerWeekIndex = (offset / 68.0).round();
    // Get the date of that week
    DateTime centerDate = startDate.add(Duration(days: centerWeekIndex * 7));
    // Update current highlighted month if changed
    if (centerDate.month != _currentMonth || centerDate.year != _currentYear) {
      setState(() {
        _currentMonth = centerDate.month;
        _currentYear = centerDate.year;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    return Center(
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: numberOfWeeks,
        itemBuilder: (context, weekIndex) {
          return _buildWeekColumn(weekIndex);
        },
      ),
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
    bool isCurrentMonth = date.month == _currentMonth && date.year == _currentYear;
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
