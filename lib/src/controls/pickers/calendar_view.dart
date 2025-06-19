import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

/// Defines the selection modes available for the [CalendarView].
enum CalendarViewSelectionMode {
  /// No selection is allowed.
  none,

  /// Only a single date can be selected.
  single,

  /// A range of dates can be selected.
  range,

  /// Multiple, non-contiguous dates can be selected.
  multiple,
}

/// Defines the display modes for the [CalendarView].
enum CalendarViewDisplayMode {
  /// Displays the calendar in month view.
  month,

  /// Displays the calendar in year view.
  year,

  /// Displays the calendar in decade view.
  decade,
}

/// A customizable calendar widget that allows users to select dates in various modes.
///
/// The [CalendarView] supports single, range, and multiple date selection modes,
/// as well as different display modes (month, year, decade). It provides options
/// for customizing appearance, selection behavior, and localization.
class CalendarView extends StatefulWidget {
  /// The initially selected start date.
  final DateTime? initialStart;

  /// The initially selected end date (used in range selection).
  final DateTime? initialEnd;

  /// Callback invoked when the selection changes.
  /// - For [CalendarViewSelectionMode.single], only [start] is provided (the selected date).
  /// - For [CalendarViewSelectionMode.range], both [start] and [end] are provided (the selected range).
  /// - For [CalendarViewSelectionMode.multiple], [multiple] contains the list of selected dates.
  /// - For [CalendarViewSelectionMode.none], the callback is not called.
  final void Function(DateTime? start,
      [DateTime? end, List<DateTime>? multiple])? onSelectionChanged;

  /// The minimum selectable date.
  final DateTime? minDate;

  /// The maximum selectable date.
  final DateTime? maxDate;

  /// The color used to highlight selected dates.
  final Color? selectionColor;

  /// The decoration for the calendar container.
  final BoxDecoration? decoration;

  /// The shape of each day cell.
  final WidgetStateProperty<ShapeBorder?>? dayShape;

  /// The initial display mode (month, year, or decade).
  final CalendarViewDisplayMode displayMode;

  /// The selection mode (none, single, range, multiple).
  final CalendarViewSelectionMode selectionMode;

  /// Whether to highlight today's date.
  final bool isTodayHighlighted;

  /// Number of weeks displayed per view (between 4 and 8).
  final int weeksPerView;

  /// Whether to enable selection of out-of-scope dates.
  final bool isOutOfScopeEnabled;

  /// The text style for the calendar header.
  final TextStyle? headerStyle;

  /// The locale used for date formatting and localization.
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
    this.headerStyle,
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
  late CalendarViewDisplayMode _displayMode;
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
      if (selectedStart != null) selectedMultiple.add(selectedStart!);
      if (selectedEnd != null) selectedMultiple.add(selectedEnd!);
    }
    _displayMode = widget.displayMode;
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
    return DateTime(
      _anchorMonth.year,
      _anchorMonth.month + (page - _initialPage),
      1,
    );
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

  Widget _buildHeader() {
    VoidCallback? onTap;

    switch (_displayMode) {
      case CalendarViewDisplayMode.month:
        onTap =
            () => setState(() => _displayMode = CalendarViewDisplayMode.year);
        break;
      case CalendarViewDisplayMode.year:
        onTap =
            () => setState(() => _displayMode = CalendarViewDisplayMode.decade);
        break;
      case CalendarViewDisplayMode.decade:
        onTap = null;
        break;
    }

    return _CalendarHeader(
      date: _visibleMonth,
      displayMode: _displayMode,
      onNext:
          _currentPage + 1 >= _monthsToShow ? null : () => _navigateMonth(1),
      onPrevious: _currentPage - 1 < 0 ? null : () => _navigateMonth(-1),
      onTap: onTap,
      style: widget.headerStyle,
      locale: widget.locale,
      showNavigation: _displayMode != CalendarViewDisplayMode.decade,
    );
  }

  Widget _buildMonthView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
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
    );
  }

  Widget _buildYearView() {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final year = _visibleMonth.year;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          children: List.generate(12, (i) {
            final month = DateTime(year, i + 1, 1);
            final isDisabled =
                (widget.minDate != null && month.isBefore(widget.minDate!)) ||
                    (widget.maxDate != null && month.isAfter(widget.maxDate!));
            final isFilled = DateTime.now().year == year &&
                DateTime.now().month == month.month;
            return _CalendarItem(
                content:
                    DateFormat.MMM(locale.toString()).format(month).titleCase,
                isDisabled: isDisabled,
                isFilled: isFilled,
                fillColor: widget.selectionColor,
                shape: widget.dayShape,
                onTapped: () {
                  setState(() {
                    _visibleMonth = month;
                    _currentPage = _initialPage +
                        (month.year - _anchorMonth.year) * 12 +
                        (month.month - _anchorMonth.month);
                    _displayMode = CalendarViewDisplayMode.month;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(_currentPage);
                    }
                  });
                });
          }),
        ),
      ],
    );
  }

  Widget _buildDecadeView() {
    final int startYear = (_visibleMonth.year ~/ 10) * 10;
    final years = List.generate(16, (i) => startYear - 1 + i);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          children: years.map((y) {
            final isCurrentYear = y == DateTime.now().year;
            final isDisabled = (widget.minDate != null &&
                    DateTime(y).isBefore(widget.minDate!)) ||
                (widget.maxDate != null &&
                    DateTime(y, 12, 31).isAfter(widget.maxDate!));
            return _CalendarItem(
              content: y.toString(),
              isDisabled:
                  isDisabled || y == startYear - 1 || y >= startYear + 10,
              onTapped: () => setState(() {
                _visibleMonth = DateTime(y, 1, 1);
                _displayMode = CalendarViewDisplayMode.year;
              }),
              fillColor: widget.selectionColor,
              isFilled: isCurrentYear,
              shape: widget.dayShape,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_displayMode) {
      case CalendarViewDisplayMode.month:
        return Container(
          decoration:
              widget.decoration ?? kPickerDecorationBuilder(context, {}),
          padding: const EdgeInsets.all(8),
          child: _buildMonthView(),
        );
      case CalendarViewDisplayMode.year:
        return Container(
          decoration:
              widget.decoration ?? kPickerDecorationBuilder(context, {}),
          padding: const EdgeInsets.all(8),
          child: _buildYearView(),
        );
      case CalendarViewDisplayMode.decade:
        return Container(
          decoration:
              widget.decoration ?? kPickerDecorationBuilder(context, {}),
          padding: const EdgeInsets.all(8),
          child: _buildDecadeView(),
        );
    }
  }
}

/// A header widget for the calendar view that displays the current date/period and navigation controls.
///
/// This widget shows the current month/year/decade based on the display mode, and provides
/// navigation buttons to move between periods. It also supports tapping the label to change
/// the display mode.
class _CalendarHeader extends StatelessWidget {
  /// The current display mode of the calendar (month, year, or decade)
  final CalendarViewDisplayMode displayMode;

  /// The date to display in the header
  final DateTime date;

  /// Callback when the previous button is pressed
  final VoidCallback? onPrevious;

  /// Callback when the next button is pressed
  final VoidCallback? onNext;

  /// Callback when the header label is tapped
  final VoidCallback? onTap;

  /// The locale to use for formatting dates
  final Locale? locale;

  /// Whether to show the navigation buttons
  final bool showNavigation;

  /// Optional text style to apply to the header label
  final TextStyle? style;

  const _CalendarHeader({
    required this.displayMode,
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onTap,
    this.locale,
    this.showNavigation = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final fLocale = locale ?? Localizations.localeOf(context);
    String label;

    switch (displayMode) {
      case CalendarViewDisplayMode.month:
        label = DateFormat.yMMMM(fLocale.toString()).format(date).titleCase;
        break;
      case CalendarViewDisplayMode.year:
        label = date.year.toString();
        break;
      case CalendarViewDisplayMode.decade:
        final startYear = (date.year ~/ 10) * 10;
        label = '$startYear - ${startYear + 9}';
        break;
    }

    return Row(
      children: [
        Expanded(
          child: IconButton(
            onPressed: onTap,
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: style ?? FluentTheme.of(context).typography.subtitle,
                ),
              ],
            ),
          ),
        ),
        if (showNavigation) ...[
          IconButton(
            icon: const Icon(FluentIcons.caret_solid_up, size: 12),
            onPressed: onPrevious,
          ),
          IconButton(
            icon: const Icon(FluentIcons.caret_solid_down, size: 12),
            onPressed: onNext,
          ),
        ]
      ],
    );
  }
}

/// A stateless widget that represents a single calendar item
/// (such as a month or a year) in a calendar view.
///
/// The [_CalendarItem] displays its [content] inside a styled [Button],
/// supporting customization for shape, fill color, and disabled state.
/// It visually distinguishes between filled, hovered, and disabled states,
/// and triggers [onTapped] when pressed (unless disabled).
///
/// Used internally by the calendar picker controls.
class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.content,
    required this.isDisabled,
    required this.onTapped,
    this.shape,
    this.fillColor,
    this.isFilled = false,
  });

  final String content;
  final bool isDisabled;
  final bool isFilled;
  final VoidCallback onTapped;
  final Color? fillColor;
  final WidgetStateProperty<ShapeBorder?>? shape;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color =
        fillColor ?? theme.accentColor.defaultBrushFor(theme.brightness);
    return Button(
      style: ButtonStyle(
        shape: shape ?? const WidgetStatePropertyAll(CircleBorder()),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (isFilled) return color;
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
      onPressed: isDisabled ? null : onTapped,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(content),
      ),
    );
  }
}

/// A widget that represents a single day item in a calendar view.
///
/// Displays the day number and handles selection, range highlighting,
/// disabled state, and custom shapes and colors. Tapping the item
/// triggers the [onDayTapped] callback if the item is not disabled.
class _CalendarDayItem extends StatelessWidget {
  /// The date represented by this day item.
  final DateTime day;

  /// Whether this day is currently selected.
  final bool isSelected;

  /// Whether this day is within a selected range.
  final bool isInRange;

  /// Whether this day is disabled and cannot be selected.
  final bool isDisabled;

  /// Whether the day item should be filled with the selection color.
  final bool isFilled;

  /// Callback invoked when the day item is tapped.
  /// Receives the [day] as a parameter.
  final void Function(DateTime) onDayTapped;

  /// The color used for selection and highlighting.
  /// If null, the default brush for the theme's accent color is used.
  final Color? selectionColor;

  /// The shape of the day item button.
  /// If null, a circular shape is used by default.
  final WidgetStateProperty<ShapeBorder?>? shape;

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

  void _onDayTapped(DateTime day) {
    onDayTapped(day);
  }

  String get d => day.day.toString();

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color =
        selectionColor ?? theme.accentColor.defaultBrushFor(theme.brightness);
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
