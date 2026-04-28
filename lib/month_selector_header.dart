import 'package:flutter/material.dart';

class MonthSelector extends StatefulWidget {
  final int monthCount;
  final int currentMonthIndex;

  const MonthSelector({
    super.key,
    required this.monthCount,
    required this.currentMonthIndex,
  });

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  final ScrollController _controller = ScrollController();
  double? _itemWidth;
  bool _jumpDone = false;

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void didUpdateWidget(MonthSelector old) {
    super.didUpdateWidget(old);
    if (widget.currentMonthIndex != old.currentMonthIndex) _animateToCurrent();
  }

  void _animateToCurrent() {
    if (!_controller.hasClients || _itemWidth == null) return;
    final viewport = _controller.position.viewportDimension;
    final target =
        widget.currentMonthIndex * _itemWidth! - (viewport - _itemWidth!) / 2;
    _controller.animateTo(
        target.clamp(
            _controller.position.minScrollExtent,
            _controller.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 75),
        curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 0.55 makes each item wider than half the viewport so adjacent months
          // peek in on both sides, giving the fade-out effect visual context.
          _itemWidth = constraints.maxWidth * 0.55;

          // first build: jump without animation so initial month is centered
          if (!_jumpDone) {
            _jumpDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_controller.hasClients) return;
              final viewport = _controller.position.viewportDimension;
              final target = widget.currentMonthIndex * _itemWidth! -
                  (viewport - _itemWidth!) / 2;
              _controller.jumpTo(target.clamp(
                _controller.position.minScrollExtent,
                _controller.position.maxScrollExtent,
              ));
            });
          }

          // the selector is display-only; scrolling is driven
          // by the parent via currentMonthIndex
          return IgnorePointer(
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: widget.monthCount,
              itemExtent: _itemWidth,
              itemBuilder: (context, index) {
                final distance =
                (index - widget.currentMonthIndex).abs().toDouble();
                final opacity = (1.0 - distance * 0.6).clamp(0.25, 1.0);
                final isCurrent = index == widget.currentMonthIndex;
                return Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      _names[index % 12],
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight:
                        isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}