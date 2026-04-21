import 'package:flutter/material.dart';
import 'day_entry.dart';

class CalendarFooter extends StatelessWidget {
  final DateTime? selectedDate;
  final List<Routine> routines;

  const CalendarFooter({
    super.key,
    required this.selectedDate,
    required this.routines,
  });

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.transparent,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
            child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
              child: child,
            ),
          ),
          child: selectedDate == null
              ? _buildEmpty()
              : _buildSelected(selectedDate!, routines),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return _Pill(
      key: const ValueKey('empty'),
      child: SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Select a date to show tasks',
            style: TextStyle(fontSize: 16, color: Colors.black26, fontWeight: FontWeight.w500),
          )
        ),
      ),
    );
  }

  Widget _buildSelected(DateTime date, List<Routine> routines) {
    return _Pill(
      key: const ValueKey('selected'),
      child: SizedBox(
        height: 80,
        child: Padding (
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // date label
              Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              // vertical divider
              Container(width: 2, height: 46, color: Colors.grey[400]),
              const SizedBox(width: 20),
              // routines list
              Expanded(
                child: routines.isEmpty
                    ? Text(
                  'No routines',
                  style: TextStyle(fontSize: 15, color: Colors.black26, fontWeight: FontWeight.w600),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: routines
                      .map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: r.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(r.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}


class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(217, 217, 217, 1.0),
        borderRadius: BorderRadius.circular(36),
      ),
      child: child,
    );
  }
}