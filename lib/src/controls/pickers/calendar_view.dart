import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

enum CalendarViewSelectionMode { none, single, range, multiple }

enum CalendarViewDisplayMode { month, year, decade }

class CalendarView extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime? start,
      [DateTime? end, List<DateTime>? multiple])? onSelectionChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? selectionColor;
  final BoxDecoration? decoration;
  final WidgetStateProperty<ShapeBorder?>? dayShape;
  final CalendarViewDisplayMode displayMode;
  final CalendarViewSelectionMode selectionMode;
  final bool isTodayHighlighted;
  final int weeksPerView;
  final bool isOutOfScopeEnabled;
  final TextStyle? monthLabelStyle;
  final Locale? locale;

  const CalendarView({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.onSelectionChanged,
    this.minDate,
    this.maxDate,
    this.dayShape,
    this.displayMode = CalendarViewDisplayMode.month,
    this.selectionMode = CalendarViewSelectionMode.single,
    this.selectionColor,
    this.isTodayHighlighted = true,
    this.decoration,
    this.monthLabelStyle,
    this.weeksPerView = 6,
    this.isOutOfScopeEnabled = false,
    this.locale,
  }) : assert(weeksPerView >= 4 && weeksPerView <= 8);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const int _yearsToShow = 100;
  static const int _monthsToShow = _yearsToShow * 12 * 2 + 1;
  static const int _initialPage = _monthsToShow ~/ 2;

  late final DateTime _anchorMonth;
  late int _currentPage;
  late DateTime _visibleMonth;
  DateTime? selectedStart;
  DateTime? selectedEnd;
  List<DateTime> selectedMultiple = [];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    selectedStart = widget.initialStart;
    selectedEnd = widget.selectionMode == CalendarViewSelectionMode.range
        ? widget.initialEnd
        : null;
    if (widget.selectionMode == CalendarViewSelectionMode.multiple) {
      if (selectedStart != null) {
        selectedMultiple.add(selectedStart!);
      }
      if (selectedEnd != null) {
        selectedMultiple.add(selectedEnd!);
      }
    }
    _anchorMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _currentPage = _initialPage;
    _visibleMonth = _monthForPage(_currentPage);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    // page 0 => 100 years before _anchorMonth
    // page _initialPage => _anchorMonth
    // page _monthsToShow-1 => 100 years after _anchorMonth
    return DateTime(
        _anchorMonth.year, _anchorMonth.month + (page - _initialPage), 1);
  }

  DateTime _getFirstVisibleDayOfWeeksView(DateTime baseMonth) {
    final firstOfMonth = DateTime(baseMonth.year, baseMonth.month, 1);
    final weekday = firstOfMonth.weekday;
    return firstOfMonth.subtract(Duration(days: weekday));
  }

  bool _isInRange(DateTime day) {
    if (selectedStart == null || selectedEnd == null) return false;
    return !day.isBefore(selectedStart!) && !day.isAfter(selectedEnd!);
  }

  bool _isSameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  void _onDayTapped(DateTime day, bool inScope) {
    if (widget.selectionMode == CalendarViewSelectionMode.none) return;
    if (!inScope && !widget.isOutOfScopeEnabled) return;

    setState(() {
      if (widget.selectionMode == CalendarViewSelectionMode.single) {
        selectedStart = _isSameDay(selectedStart, day) ? null : day;
        selectedEnd = null;
        widget.onSelectionChanged?.call(selectedStart);
      } else if (widget.selectionMode == CalendarViewSelectionMode.range) {
        if (selectedStart == null || selectedEnd != null) {
          selectedStart = day;
          selectedEnd = null;
        } else if (selectedStart != null && selectedEnd == null) {
          if (day.isBefore(selectedStart!)) {
            selectedEnd = selectedStart;
            selectedStart = day;
          } else {
            selectedEnd = day;
          }
          widget.onSelectionChanged?.call(selectedStart!, selectedEnd!);
        }
      } else if (widget.selectionMode == CalendarViewSelectionMode.multiple) {
        bool alreadySelected = selectedMultiple.any((d) => _isSameDay(d, day));
        if (alreadySelected) {
          selectedMultiple.removeWhere((d) => _isSameDay(d, day));
        } else {
          selectedMultiple.add(day);
        }
        // Sort for visual consistency
        selectedMultiple.sort((a, b) => a.compareTo(b));
        widget.onSelectionChanged?.call(
          selectedMultiple.isNotEmpty ? selectedMultiple.first : null,
          selectedMultiple.length > 1 ? selectedMultiple.last : null,
          List.unmodifiable(selectedMultiple),
        );
      }
    });
  }

  List<Widget> _buildWeekDays(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final symbols = DateFormat.E(locale.toString()).dateSymbols.SHORTWEEKDAYS;
    return List.generate(7, (i) {
      final weekdayIndex = i % 7;
      return Expanded(
        child: Center(
          child: Text(
            symbols[weekdayIndex == 7 ? 0 : weekdayIndex].titleCase,
            style: FluentTheme.of(context).typography.body,
          ),
        ),
      );
    });
  }

  Widget _buildWeeksGrid(DateTime forMonth) {
    final List<Widget> rows = [];
    final DateTime firstDay = _getFirstVisibleDayOfWeeksView(forMonth);
    final DateTime currentMonth = DateTime(forMonth.year, forMonth.month);

    for (int week = 0; week < widget.weeksPerView; week++) {
      final List<Widget> days = [];
      for (int d = 0; d < 7; d++) {
        final day = firstDay.add(Duration(days: week * 7 + d));
        final isOutOfScope =
            (widget.minDate != null && day.isBefore(widget.minDate!)) ||
                (widget.maxDate != null && day.isAfter(widget.maxDate!));
        final isCurrentMonth =
            day.month == currentMonth.month && day.year == currentMonth.year;
        final isSelected =
            widget.selectionMode == CalendarViewSelectionMode.single
                ? _isSameDay(day, selectedStart)
                : widget.selectionMode == CalendarViewSelectionMode.range
                    ? (_isSameDay(day, selectedStart) ||
                        _isSameDay(day, selectedEnd))
                    : selectedMultiple.any((d) => _isSameDay(day, d));
        final isInRange =
            widget.selectionMode == CalendarViewSelectionMode.range &&
                selectedStart != null &&
                selectedEnd != null &&
                _isInRange(day);
        final isToday =
            widget.isTodayHighlighted && _isSameDay(day, DateTime.now());

        days.add(
          Expanded(
            child: _CalendarDayItem(
              day: day,
              isSelected: isSelected,
              isInRange: isInRange,
              isDisabled: isOutOfScope ||
                  (!widget.isOutOfScopeEnabled && !isCurrentMonth),
              onDayTapped: (date) => _onDayTapped(date, !isOutOfScope),
              shape: widget.dayShape,
              selectionColor: widget.selectionColor,
              isFilled: isToday,
            ),
          ),
        );
      }
      rows.add(Row(children: days));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  void _navigateMonth(int offset) {
    final newPage = _currentPage + offset;
    if (newPage < 0 || newPage >= _monthsToShow) return;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    return Container(
      decoration: widget.decoration ?? kPickerDecorationBuilder(context, {}),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month navigation
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(locale.toString())
                        .format(_visibleMonth)
                        .titleCase,
                    style: widget.monthLabelStyle ??
                        FluentTheme.of(context).typography.subtitle,
                  ),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.caret_solid_up, size: 12),
                  onPressed:
                      _currentPage - 1 < 0 ? null : () => _navigateMonth(-1),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.caret_solid_down, size: 12),
                  onPressed: _currentPage + 1 >= _monthsToShow
                      ? null
                      : () => _navigateMonth(1),
                ),
              ],
            ),
          ),
          const Divider(
            style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
          ),
          const SizedBox(height: 4),
          Row(children: _buildWeekDays(context)),
          const SizedBox(height: 4),
          SizedBox(
            height: widget.weeksPerView * 38.0,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              pageSnapping: true,
              itemCount: _monthsToShow,
              onPageChanged: (index) {
                setState(() {
                  _visibleMonth = _monthForPage(index);
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final month = _monthForPage(index);
                return _buildWeeksGrid(month);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayItem extends StatelessWidget {
  const _CalendarDayItem({
    required this.day,
    required this.isSelected,
    required this.isInRange,
    required this.isDisabled,
    required this.onDayTapped,
    this.shape,
    this.selectionColor,
    this.isFilled = false,
  });

  final DateTime day;
  final bool isSelected;
  final bool isInRange;
  final bool isDisabled;
  final bool isFilled;
  final void Function(DateTime) onDayTapped;
  final Color? selectionColor;
  final WidgetStateProperty<ShapeBorder?>? shape;

  void _onDayTapped(DateTime day) {
    onDayTapped(day);
  }

  String get d => day.day.toString();

  @override
  Widget build(BuildContext context) {
    final color = selectionColor ?? FluentTheme.of(context).accentColor;
    return Button(
      style: ButtonStyle(
        shape: shape ??
            WidgetStateProperty.resolveWith((states) {
              return CircleBorder(
                side: BorderSide(
                  width: 1,
                  color: isSelected ? color : Colors.transparent,
                ),
              );
            }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (isFilled) return color;
          if (isInRange) return color.withAlpha(50);
          if (isDisabled) return Colors.transparent;
          if (states.contains(WidgetState.hovered)) {
            return color.withAlpha(20);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (isDisabled) {
            return FluentTheme.of(context).resources.textFillColorDisabled;
          }
          if (isFilled) {
            return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
          }
          return FluentTheme.of(context).resources.textFillColorPrimary;
        }),
      ),
      onPressed: isDisabled ? null : () => _onDayTapped(day),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(d),
      ),
    );
  }
}
