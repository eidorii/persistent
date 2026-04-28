import 'package:flutter/material.dart';
import 'dart:async';
import 'day_entry.dart';
import 'month_selector_header.dart';
import 'calendar_footer.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime startDate = DateTime(2023, 1, 1);
  static const int numberOfWeeks = 520;
  static const int _monthCount = 120;

  final ScrollController _scrollController = ScrollController();
  late final DateTime _gridEpoch;

  // single field instead of separate _currentMonth / _currentYear
  late DateTime _currentYearMonth;

  Timer? _scrollEndTimer;
  DateTime? _selectedDate;
  final Map<DateTime, DayEntry> _dayEntries = {};

  double? _columnWidth;
  bool _initialJumpDone = false;

  int get _currentMonthIndex =>
      (_currentYearMonth.year - startDate.year) * 12 +
      (_currentYearMonth.month - 1);

  @override
  void initState() {
    super.initState();

    // the grid must start on a Monday so every column is exactly one week
    final s = DateTime.utc(startDate.year, startDate.month, startDate.day);
    _gridEpoch = s.subtract(Duration(days: s.weekday - 1));

    final now = DateTime.now();
    _currentYearMonth = DateTime(now.year, now.month);

    // placeholder data — remove once real persistence is wired up
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    _dayEntries[todayUtc] = DayEntry(
      date: todayUtc,
      routines: [
        Routine(name: 'Gym', color: Colors.redAccent),
        Routine(name: 'Jog', color: Colors.amber),
        Routine(name: 'Work', color: Colors.lightBlue),
      ],
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_columnWidth == null) return;

    final viewportWidth = _scrollController.position.viewportDimension;
    final middleOffset = _scrollController.offset + viewportWidth / 2;
    final middleWeekIndex = (middleOffset / _columnWidth!).floor();
    // sample Wednesday (+3) so a week split across two months resolves to whichever
    // month owns the majority of that week's days
    final middleDate = _gridEpoch.add(Duration(days: middleWeekIndex * 7 + 3));
    if (middleDate.month != _currentYearMonth.month ||
        middleDate.year != _currentYearMonth.year) {
      setState(() {
        _currentYearMonth = DateTime(middleDate.year, middleDate.month);
      });
    }

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

    // find the Monday on or before the 1st of the highlighted month
    final firstOfMonth =
        DateTime.utc(_currentYearMonth.year, _currentYearMonth.month, 1);
    final firstMonday =
        firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
    final weeksToFirstMonday =
        firstMonday.difference(_gridEpoch).inDays ~/ 7;
    final targetOffset = weeksToFirstMonday * _columnWidth!;

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: const Color.fromRGBO(217, 217, 217, 1.0),
            child: MonthSelector(
              monthCount: _monthCount,
              currentMonthIndex: _currentMonthIndex,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _columnWidth = constraints.maxWidth / 6;

        // _columnWidth is only known after the first layout pass, so the
        // initial scroll jump must be deferred via addPostFrameCallback
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
      },
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
    final isCurrentMonth = date.month == _currentYearMonth.month &&
        date.year == _currentYearMonth.year;
    final isWeekday = date.weekday < 6;
    final isSelected = _selectedDate != null && date == _selectedDate;
    final color = isSelected
        ? const Color.fromRGBO(75, 75, 75, 1.0)
        : isCurrentMonth
            ? (isWeekday
                ? const Color.fromRGBO(217, 217, 217, 1.0)
                : const Color.fromRGBO(241, 164, 164, 1.0))
            : (isWeekday
                ? const Color.fromRGBO(227, 227, 227, 0.5)
                : const Color.fromRGBO(248, 203, 203, 1.0));
    final textColor = isSelected
        ? Colors.white
        : (isCurrentMonth ? Colors.black87 : Colors.black26);

    return GestureDetector(
      onTap: () => _onDayTap(date),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 55,
        width: 55,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            child: Text('${date.day}'),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final entry = _selectedDate != null ? _dayEntries[_selectedDate] : null;
    return CalendarFooter(
        selectedDate: _selectedDate, routines: entry?.routines ?? []);
  }
}
