import 'package:flutter/material.dart';
import 'dart:async';
import 'day_entry.dart';
import 'month_selector.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime startDate = DateTime(2023, 1, 1);
  final int numberOfWeeks = 520;
  final ScrollController _scrollController = ScrollController();
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  Timer? _scrollEndTimer;
  DateTime? _selectedDate;
  final Map<DateTime, DayEntry> _dayEntries = {};
  static const int _monthCount = 120;

  double? _columnWidth;
  bool _initialJumpDone = false;

  DateTime get _gridEpoch {
    final s = DateTime.utc(startDate.year, startDate.month, startDate.day);
    return s.subtract(Duration(days: s.weekday - 1));
  }

  int get _currentMonthIndex =>
    (_currentYear - startDate.year) * 12 + (_currentMonth - 1);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_columnWidth == null) return;

    final viewportWidth = _scrollController.position.viewportDimension;
    final middleOffset = _scrollController.offset + viewportWidth / 2;
    final middleWeekIndex = (middleOffset / _columnWidth!).floor();
    final middleDate = _gridEpoch.add(Duration(days: middleWeekIndex * 7 + 3));
    // Update current highlighted month if changed
    if (middleDate.month != _currentMonth || middleDate.year != _currentYear) {
      setState(() {
        _currentMonth = middleDate.month;
        _currentYear = middleDate.year;
      });
    }

    // reset snap timer on scroll
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 300), _snapToMonth);
  }

  DayEntry _entryFor(DateTime date) {
    final key = DateTime.utc(date.year, date.month, date.day);
    return _dayEntries.putIfAbsent(key, () => DayEntry(date: key));
  }

  void _onDayTap(DateTime date) {
    final entry = _entryFor(date);
    final isSelected = _selectedDate == entry.date;
    setState(() {
      _selectedDate = isSelected ? null : entry.date;
    });
    if (isSelected) {
      debugPrint('Deselected ${entry.date.toIso8601String().split('T').first}');
    } else {
      debugPrint('Selected ${entry.date.toIso8601String().split('T').first} '
          '- routines: ${entry.routines}');
    }
  }

  void _snapToMonth() {
    if (_columnWidth == null || !_scrollController.hasClients) return;

    // find the first Monday of the current highlighted month
    final firstOfMonth = DateTime.utc(_currentYear, _currentMonth, 1);
    final firstMonday = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
    final weeksToFirstMonday = firstMonday.difference(_gridEpoch).inDays ~/ 7;
    final targetOffset = weeksToFirstMonday * _columnWidth!;

    // snap to that position
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildCalendarGrid(),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      alignment: Alignment.bottomCenter,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: Colors.grey[200],
                      child: MonthSelector(
                          startYear: startDate.year,
                          monthCount: _monthCount,
                          currentMonthIndex: _currentMonthIndex
                      ),
                    ),
                  ),
                )
              )
            )
          ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 140,
      color: Colors.grey[300],
    );
  }

  Widget _buildCalendarGrid() {
    return LayoutBuilder(
        builder: (context, constraints) {
          _columnWidth = constraints.maxWidth / 6;

          if (!_initialJumpDone) {
            _initialJumpDone = true;
            final now = DateTime.now();
            final todayUtc = DateTime.utc(now.year, now.month, now.day);
            final weeksSinceStart =
                todayUtc.difference(_gridEpoch).inDays ~/ 7;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(weeksSinceStart * _columnWidth!);
              }
            });
          }
          return ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemExtent: _columnWidth,
              itemCount: numberOfWeeks,
              itemBuilder: (context, weekIndex) => _buildWeekColumn(weekIndex),
          );
        }
    );
  }

  Widget _buildWeekColumn(int weekIndex) {
    final monday = _gridEpoch.add(Duration(days: weekIndex * 7));
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (dayIndex) {
        return _buildDayCell(monday.add(Duration(days: dayIndex)));
      }),
    );
  }

  Widget _buildDayCell(DateTime date) {
    bool isCurrentMonth = date.month == _currentMonth && date.year == _currentYear;
    bool isWeekday = date.weekday < 6;
    final isSelected = _selectedDate != null &&
      date.year == _selectedDate!.year &&
      date.month == _selectedDate!.month &&
      date.day == _selectedDate!.day;
    return GestureDetector(
      onTap: () => _onDayTap(date),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 55,
        width: 55,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color: isSelected
            ? const Color.fromRGBO(75, 75, 75, 1.0)
            : isCurrentMonth
              ? (isWeekday
                    ? Colors.grey[300]
                    : Color.fromRGBO(241, 164, 164, 1.0))
              : (isWeekday
                    ? Colors.grey[200]
                    : Color.fromRGBO(248, 203, 203, 1.0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isCurrentMonth ? Colors.black87 : Colors.black26),
            ),
          ),
        ),
      ),
    );
  }
}
