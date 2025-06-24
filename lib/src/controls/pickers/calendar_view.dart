import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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

/// Represents the selection data for the [CalendarView].
class CalendarSelectionData {
  /// The list of selected dates.
  final List<DateTime> selectedDates;

  /// The start date of the selection range, if applicable.
  final DateTime? startDate;

  /// The end date of the selection range, if applicable.
  final DateTime? endDate;

  CalendarSelectionData({
    required this.selectedDates,
    this.startDate,
    this.endDate,
  }) : assert(
         startDate == null || endDate == null || startDate.isBefore(endDate),
         'Start date must be before end date if both are provided.',
       );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalendarSelectionData &&
        listEquals(other.selectedDates, selectedDates) &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode =>
      selectedDates.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

/// A calendar view lets a user view and interact with a calendar that they can
/// navigate by month, year, or decade. A user can select a single date or a
/// range of dates. It doesn't have a picker surface and the calendar is always
/// visible.
///
/// ![](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/calendar-view-3-views.png)
///
/// See also:
///
///  * [DatePicker], which provides a more compact date selection interface.
///  * [TimePicker], which allows users to select a time.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/calendar-view>
class CalendarView extends StatefulWidget {
  /// The initial start date for selection.
  final DateTime? initialStart;

  /// The initial end date for range selection.
  final DateTime? initialEnd;

  /// Callback invoked when the selection changes.
  ///
  /// This provides a [CalendarSelectionData] object containing the selected
  /// dates, start date, and end date.
  ///
  /// See also:
  ///
  ///   * [CalendarSelectionData] for details on the selection data structure.
  final ValueChanged<CalendarSelectionData>? onSelectionChanged;

  /// The minimum date that can be selected.
  final DateTime? minDate;

  /// The maximum date that can be selected.
  final DateTime? maxDate;

  /// The color used to highlight selected dates.
  ///
  /// If null, the default accent color from the theme is used.
  final Color? selectionColor;

  /// The decoration for the calendar container.
  final Decoration? decoration;

  /// The shape of the day item buttons.
  final ShapeBorder? dayItemShape;

  /// The initial display mode of the calendar view.
  ///
  /// Defaults to [CalendarViewDisplayMode.month].
  final CalendarViewDisplayMode initialDisplayMode;

  /// The selection mode for the calendar view.
  ///
  /// Defaults to [CalendarViewSelectionMode.single].
  final CalendarViewSelectionMode selectionMode;

  /// If provided, this function determines if a date should be blacked out.
  ///
  /// Any date respecting this rule will be considered as a "blackout" date, meaning
  /// users will not be able to select it. This is useful for preventing selection
  /// of holidays, weekends, or other restricted dates.
  ///
  /// Example:
  /// ```dart
  /// // To blackout all weekends
  /// blackoutRule: (date) => date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
  /// ```
  final bool Function(DateTime date)? blackoutRule;

  /// Whether to highlight today's date.
  ///
  /// Defaults to true.
  final bool isTodayHighlighted;

  /// The number of weeks to display in the month view.
  ///
  /// It can be set to a value between 4 and 8, with the default being 6.
  final int weeksPerView;

  /// The number of years to display in the year view.
  ///
  /// Every row contains 4 years, so the total number of years per view must
  /// be a multiple of 4.
  ///
  /// Defaults to 16 years per view.
  final int yearsPerView;

  /// The first day of the week.
  ///
  /// Defaults to the system's first day of the week.
  ///
  /// Monday is 1, Tuesday is 2, Wednesday is 3, Thursday is 4, Friday is 5,
  /// Saturday is 6, and Sunday is 7.
  ///
  /// See also:
  ///
  ///  * [DateTime.weekday] for the weekday values.
  final int? firstDayOfWeek;

  /// Whether to enable selection of out-of-scope dates.
  ///
  /// If enabled, users can select dates that are outside the days of the
  /// visible month.
  ///
  /// If disabled, out-of-scope dates will be visually distinct and cannot be
  /// selected.
  ///
  /// Defaults to false.
  final bool isOutOfScopeEnabled;

  /// Whether to show the group label for the first day of each month.
  ///
  /// Defaults to true.
  final bool isGroupLabelVisible;

  /// The text style for the calendar header.
  final TextStyle? headerStyle;

  /// The locale to use for formatting dates in the calendar.
  final Locale? locale;

  /// Creates a new [CalendarView].
  CalendarView({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.onSelectionChanged,
    this.minDate,
    this.maxDate,
    this.dayItemShape,
    this.initialDisplayMode = CalendarViewDisplayMode.month,
    this.selectionMode = CalendarViewSelectionMode.single,
    this.selectionColor,
    this.blackoutRule,
    this.isTodayHighlighted = true,
    this.decoration,
    this.headerStyle,
    this.weeksPerView = 6,
    this.yearsPerView = 16,
    this.firstDayOfWeek,
    this.isOutOfScopeEnabled = false,
    this.locale,
    this.isGroupLabelVisible = true,
  }) : assert(weeksPerView >= 4 && weeksPerView <= 8),
       assert(yearsPerView > 0, 'yearsPerView must be greater than 0'),
       assert(yearsPerView % 4 == 0, 'yearsPerView must be a multiple of 4'),
       assert(
         firstDayOfWeek == null || (firstDayOfWeek >= 1 && firstDayOfWeek <= 7),
         'firstDayOfWeek must be between 1 and 7, or null for system default',
       ),
       assert(
         initialStart == null ||
             initialEnd == null ||
             initialStart.isBefore(initialEnd),
         'initialStart must be before initialEnd if both are provided.',
       );

  @override
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  /// The anchor month is the month that the calendar is currently centered on.
  late DateTime _anchorMonth;
  late CalendarViewDisplayMode _displayMode = widget.initialDisplayMode;
  late DateTime? _selectedStart = widget.initialStart;
  late DateTime? _selectedEnd =
      widget.selectionMode == CalendarViewSelectionMode.range
      ? widget.initialEnd
      : null;
  final _selectedMultiple = <DateTime>[];

  final _monthScrollController = ScrollController();
  final _yearScrollController = ScrollController();
  final _decadeScrollController = ScrollController();

  /// Describes the date that is currently visible in the calendar when
  /// scrolling.
  DateTime? _scrollDate;

  static const double _rowHeight = 40.0;
  static const double _yearRowHeight = 70.0;

  /// The currently visible date in the calendar.
  DateTime get visibleDate {
    return _scrollDate ?? _anchorMonth;
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectionMode == CalendarViewSelectionMode.multiple) {
      if (_selectedStart != null) _selectedMultiple.add(_selectedStart!);
      if (_selectedEnd != null) _selectedMultiple.add(_selectedEnd!);
    }
    final anchor = widget.initialStart ?? DateTime.now();
    _anchorMonth = DateTime(anchor.year, anchor.month, 1);

    _monthScrollController.addListener(_monthScrollListener);
    _yearScrollController.addListener(_yearScrollListener);
    _decadeScrollController.addListener(_decadeScrollListener);
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    _yearScrollController.dispose();
    _decadeScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectionMode != oldWidget.selectionMode) {
      // Reset selection state if the selection mode changes
      _selectedStart = widget.initialStart;
      _selectedEnd = widget.selectionMode == CalendarViewSelectionMode.range
          ? widget.initialEnd
          : null;
      _selectedMultiple.clear();
      if (_selectedStart != null) _selectedMultiple.add(_selectedStart!);
      if (_selectedEnd != null) _selectedMultiple.add(_selectedEnd!);
    }
  }

  void _monthScrollListener() {
    final pixels = _monthScrollController.position.pixels;
    final rowIndex = (pixels / _rowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.month) {
      setState(() {
        // todo(kv): work pretty well when adding 10 days.
        //  It is maybe due because of bug of the duplicated week in June.
        _scrollDate = _daysFromAnchor((rowIndex * 7 + 10).toInt());
      });
    }
  }

  void _yearScrollListener() {
    final pixels = _yearScrollController.position.pixels;
    final rowIndex = (pixels / _yearRowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.year) {
      final page = (rowIndex / 4).round();
      setState(() {
        _scrollDate = _yearForPage(page);
      });
    }
  }

  void _decadeScrollListener() {
    final pixels = _decadeScrollController.position.pixels;
    final rowIndex = (pixels / _yearRowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.decade) {
      setState(() {
        _scrollDate = DateTime(_anchorMonth.year + rowIndex, 1, 1);
      });
    }
  }

  DateTime _daysFromAnchor(int days) {
    return DateTime(
      _anchorMonth.year,
      _anchorMonth.month,
      1,
    ).add(Duration(days: days));
  }

  DateTime _yearForPage(int page) {
    return DateTime(_anchorMonth.year + page, _anchorMonth.month, 1);
  }

  /// Navigates to the specified month in the calendar view.
  void navigateToMonth(DateTime date) {
    setState(() {
      _scrollDate = null;
      _anchorMonth = DateTime(date.year, date.month, 1);
      _displayMode = CalendarViewDisplayMode.month;
    });
    if (_monthScrollController.hasClients) {
      _monthScrollController.jumpTo(0);
    }
  }

  /// Steps to the next or previous month based on the offset.
  ///
  /// If the offset is positive, it navigates to a future month. If negative,
  /// it navigates to a past month.
  void stepMonth({int offset = 0}) {
    final offsetDate = DateTime(
      visibleDate.year,
      visibleDate.month + offset,
      1,
    );
    navigateToMonth(offsetDate);
  }

  /// Navigates to the specified year in the calendar view.
  void navigateToYear(DateTime date) {
    setState(() {
      _scrollDate = null;
      _anchorMonth = DateTime(date.year, date.month, 1);
      _displayMode = CalendarViewDisplayMode.year;
    });
    if (_yearScrollController.hasClients) {
      _yearScrollController.jumpTo(0);
    }
  }

  /// Steps to the next or previous year based on the offset.
  ///
  /// If the offset is positive, it navigates to a future year. If negative,
  /// it navigates to a past year.
  void stepYear({int offset = 0}) {
    navigateToYear(_yearForPage(offset));
  }

  bool _isInRange(DateTime day) {
    if (_selectedStart == null || _selectedEnd == null) return false;
    return !day.isBefore(_selectedStart!) && !day.isAfter(_selectedEnd!);
  }

  void _onDayTapped(DateTime day, bool inScope) {
    if (!inScope && !widget.isOutOfScopeEnabled) return;

    setState(() {
      switch (widget.selectionMode) {
        case CalendarViewSelectionMode.single:
          _selectedStart = DateUtils.isSameDay(_selectedStart, day)
              ? null
              : day;
          _selectedEnd = null;
          widget.onSelectionChanged?.call(
            CalendarSelectionData(
              selectedDates: _selectedStart != null ? [_selectedStart!] : [],
              startDate: _selectedStart,
              endDate: null,
            ),
          );
          break;
        case CalendarViewSelectionMode.range:
          if (_selectedStart == null || _selectedEnd != null) {
            _selectedStart = day;
            _selectedEnd = null;
          } else if (_selectedStart != null && _selectedEnd == null) {
            if (day.isBefore(_selectedStart!)) {
              _selectedEnd = _selectedStart;
              _selectedStart = day;
            } else {
              _selectedEnd = day;
            }
            widget.onSelectionChanged?.call(
              CalendarSelectionData(
                selectedDates: [?_selectedStart, ?_selectedEnd],
                startDate: _selectedStart,
                endDate: _selectedEnd,
              ),
            );
          }
          break;
        case CalendarViewSelectionMode.multiple:
          final alreadySelected = _selectedMultiple.any(
            (d) => DateUtils.isSameDay(d, day),
          );
          if (alreadySelected) {
            _selectedMultiple.removeWhere((d) => DateUtils.isSameDay(d, day));
          } else {
            _selectedMultiple.add(day);
          }
          _selectedMultiple.sort((a, b) => a.compareTo(b));
          widget.onSelectionChanged?.call(
            CalendarSelectionData(
              selectedDates: List.unmodifiable(_selectedMultiple),
              startDate: _selectedMultiple.isNotEmpty
                  ? _selectedMultiple.first
                  : null,
              endDate: _selectedMultiple.length > 1
                  ? _selectedMultiple.last
                  : null,
            ),
          );
          break;
        default:
          return;
      }
    });
  }

  /// Gets the first day of the week based on the current locale.
  int get firstDayOfWeek {
    final locale = widget.locale ?? Localizations.localeOf(context);
    return widget.firstDayOfWeek ??
        (DateFormat.yMd(locale.toString()).dateSymbols.FIRSTDAYOFWEEK + 1);
  }

  Widget _buildWeekDays(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final symbols = DateFormat.E(
      locale.toString(),
    ).dateSymbols.STANDALONESHORTWEEKDAYS;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Text(
                    symbols[(firstDayOfWeek + i) % 7],
                    style: FluentTheme.of(context).typography.body?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayItem(DateTime day) {
    final locale = widget.locale ?? Localizations.localeOf(context);

    final isBlackout =
        (widget.minDate != null && day.isBefore(widget.minDate!)) ||
        (widget.maxDate != null && day.isAfter(widget.maxDate!)) ||
        (widget.blackoutRule?.call(day) ?? false);
    final isCurrentMonth = DateUtils.isSameMonth(day, visibleDate);
    final isFirstMonthDay = DateUtils.isSameDay(
      day,
      DateTime(day.year, day.month),
    );
    final isSelected = widget.selectionMode == CalendarViewSelectionMode.single
        ? DateUtils.isSameDay(day, _selectedStart)
        : widget.selectionMode == CalendarViewSelectionMode.range
        ? (DateUtils.isSameDay(day, _selectedStart) ||
              DateUtils.isSameDay(day, _selectedEnd))
        : _selectedMultiple.any((d) => DateUtils.isSameDay(day, d));
    final isInRange =
        widget.selectionMode == CalendarViewSelectionMode.range &&
        _selectedStart != null &&
        _selectedEnd != null &&
        _isInRange(day);
    final isToday =
        widget.isTodayHighlighted && DateUtils.isSameDay(day, DateTime.now());

    return _CalendarDayItem(
      day: day,
      isSelected: isSelected,
      isInRange: isInRange,
      isOutOfScope: !widget.isOutOfScopeEnabled && !isCurrentMonth,
      isBlackout: isBlackout,
      onDayTapped: (date) => _onDayTapped(date, !isBlackout),
      shape: widget.dayItemShape,
      selectionColor: widget.selectionColor,
      isFilled: isToday,
      showGroupLabel: widget.isGroupLabelVisible && isFirstMonthDay,
      locale: locale,
    );
  }

  Widget _buildHeader() {
    VoidCallback? onTap, onNext, onPrevious;

    switch (_displayMode) {
      case CalendarViewDisplayMode.month:
        onTap = () {
          setState(() {
            stepYear();
            _displayMode = CalendarViewDisplayMode.year;
          });
        };
        onNext = () => stepMonth(offset: 1);
        onPrevious = () => stepMonth(offset: -1);
        break;
      case CalendarViewDisplayMode.year:
        onTap = () =>
            setState(() => _displayMode = CalendarViewDisplayMode.decade);
        onNext = () => stepYear(offset: 1);
        onPrevious = () => stepYear(offset: -1);
        break;
      case CalendarViewDisplayMode.decade:
        break;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 8.0,
        end: 8.0,
        top: 8.0,
        bottom: 4.0,
      ),
      child: _CalendarHeader(
        date: visibleDate,
        displayMode: _displayMode,
        onNext: onNext,
        onPrevious: onPrevious,
        onTap: _displayMode == CalendarViewDisplayMode.decade ? null : onTap,
        style: widget.headerStyle,
        locale: widget.locale,
        showNavigation: _displayMode != CalendarViewDisplayMode.decade,
      ),
    );
  }

  /// Calculates the negative index for a grid item based on its index and
  /// the number of columns in the grid.
  ///
  /// The problem is that the reverse grid layout starts at the leftmost item,
  /// causing this situation:
  ///
  /// [... ,-7, -8, -9, -10, -11, -12, -13, -0, -1, -2, -3, -4, -5, -6, 1, 2, 3, 4, 5, 6, 7, 8 , 9, 10, 11, 12, 13, 14, ...]
  ///
  /// The function calculates the row and column of the item in the grid,
  /// then computes the index as if the items in the row were reversed.
  /// Finally, it converts the 0-based swapped index to the final negative
  /// display index.
  ///
  /// [.... ,-14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, ...]
  int _getNegativeIndex(int index, int crossAxisCount) {
    final int row = index ~/ crossAxisCount;
    final int col = index % crossAxisCount;

    // Calculate the index as if the items in the row were reversed.
    // This finds the "mirror" index within the same row.
    final int swappedIndexInRow = crossAxisCount - 1 - col;
    final int swappedBuilderIndex = (row * crossAxisCount) + swappedIndexInRow;

    // Convert the 0-based swapped index to the final negative display index.
    return -swappedBuilderIndex - 1;
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
        _buildWeekDays(context),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          height: widget.weeksPerView * _rowHeight,
          child: Builder(
            builder: (context) {
              final forwardListKey = UniqueKey();

              // The offset describes how many days from the first day of the
              // week. This align the first week of the month correctly.
              final offset = (_anchorMonth.weekday - firstDayOfWeek + 7) % 7;

              const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                mainAxisExtent: _rowHeight,
              );

              final reverseGrid = SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final negativeIndex = _getNegativeIndex(index, 7) + offset;
                  final day = _anchorMonth.add(Duration(days: negativeIndex));

                  return _buildDayItem(day);
                }),
              );

              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final day = _anchorMonth.add(Duration(days: index - offset));

                  return _buildDayItem(day);
                }),
              );

              return CustomScrollView(
                controller: _monthScrollController,
                center: forwardListKey,
                slivers: [reverseGrid, forwardGrid],
              );
            },
          ),
        ),
      ],
    );
  }

  double get _yearViewHeight => (widget.yearsPerView / 4) * _yearRowHeight;
  Widget _buildYearView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _yearViewHeight,
          child: Builder(
            builder: (context) {
              final forwardListKey = UniqueKey();

              const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
              );

              final reverseGrid = SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final nIndex = _getNegativeIndex(index, 4);
                  final year = _anchorMonth.year + (nIndex ~/ 12);
                  final monthNumber = (nIndex % 12) + 1;
                  return _buildYearItem(year, monthNumber);
                }),
              );

              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final year = _anchorMonth.year + (index ~/ 12);
                  final monthNumber = (index % 12) + 1;

                  return _buildYearItem(year, monthNumber);
                }),
              );

              return CustomScrollView(
                controller: _yearScrollController,
                center: forwardListKey,
                slivers: [reverseGrid, forwardGrid],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearItem(int year, int monthNumber) {
    final locale = widget.locale ?? Localizations.localeOf(context);

    final isValidMonth = monthNumber >= 1 && monthNumber <= 12;
    final month = isValidMonth
        ? DateTime(year, monthNumber, 1)
        : DateTime(year + (monthNumber ~/ 12), monthNumber % 12);
    final isDisabled =
        !isValidMonth ||
        (widget.minDate != null && month.isBefore(widget.minDate!)) ||
        (widget.maxDate != null && month.isAfter(widget.maxDate!));
    final isFilled =
        isValidMonth &&
        DateTime.now().year == year &&
        DateTime.now().month == monthNumber;
    final showGroupLabel = widget.isGroupLabelVisible && month.month == 1;
    return _CalendarItem(
      content: DateFormat.MMM(locale.toString()).format(month).titleCase,
      isDisabled: isDisabled,
      isFilled: isFilled,
      fillColor: widget.selectionColor,
      shape: widget.dayItemShape,
      groupLabel: showGroupLabel
          ? DateFormat.y(locale.toString()).format(month)
          : null,
      onTapped: () {
        setState(() {
          _displayMode = CalendarViewDisplayMode.month;
          _anchorMonth = month;
        });
      },
    );
  }

  Widget _buildDecadeView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _yearViewHeight,
          child: Builder(
            builder: (context) {
              final forwardListKey = UniqueKey();

              const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
              );

              final reverseGrid = SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final nIndex = _getNegativeIndex(index, 4);
                  final year = _anchorMonth.year + nIndex;
                  return _buildDecadeItem(year);
                }),
              );

              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final year = _anchorMonth.year + index;

                  return _buildDecadeItem(year);
                }),
              );

              return CustomScrollView(
                controller: _decadeScrollController,
                center: forwardListKey,
                slivers: [reverseGrid, forwardGrid],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDecadeItem(int year) {
    final isCurrentYear = year == DateTime.now().year;
    final isDisabled =
        (widget.minDate != null && DateTime(year).isBefore(widget.minDate!)) ||
        (widget.maxDate != null &&
            DateTime(year, 12, 31).isAfter(widget.maxDate!));
    return _CalendarItem(
      content: year.toString(),
      isDisabled: isDisabled,
      onTapped: () => setState(() {
        _displayMode = CalendarViewDisplayMode.year;
      }),
      fillColor: widget.selectionColor,
      isFilled: isCurrentYear,
      shape: widget.dayItemShape,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.resources.controlFillColorInputActive,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              width: 1,
              color: theme.resources.controlStrokeColorDefault,
            ),
          ),
      constraints: const BoxConstraints(maxWidth: 300, minHeight: 350),
      child: switch (_displayMode) {
        CalendarViewDisplayMode.month => _buildMonthView(),
        CalendarViewDisplayMode.year => _buildYearView(),
        CalendarViewDisplayMode.decade => _buildDecadeView(),
      },
    );
  }
}

/// A header widget for the calendar view that displays the current date/period
/// and navigation controls.
///
/// This widget shows the current month/year/decade based on the display mode,
/// and provides navigation buttons to move between periods. It also supports
/// tapping the label to change the display mode.
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
    final theme = FluentTheme.of(context);
    final locale = this.locale ?? Localizations.localeOf(context);
    String label;

    switch (displayMode) {
      case CalendarViewDisplayMode.month:
        label = DateFormat.yMMMM(locale.toLanguageTag()).format(date).titleCase;
        break;
      case CalendarViewDisplayMode.year:
        label = date.year.toString();
        break;
      case CalendarViewDisplayMode.decade:
        final startYear = (date.year ~/ 10) * 10;
        final endYear = startYear + 9;
        label = '$startYear - $endYear';
        break;
    }

    final foregroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.isDisabled) return theme.resources.textFillColorDisabled;
      return null;
    });

    return IntrinsicHeight(
      child: Row(
        spacing: 4,
        children: [
          Expanded(
            child: IconButton(
              onPressed: onTap,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  // This keeps the same background color when the button is
                  // disabled
                  (states) => ButtonThemeData.uncheckedInputColor(
                    theme,
                    states,
                    transparentWhenNone: true,
                    transparentWhenDisabled: true,
                  ),
                ),
              ),
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      return Text(
                        label,
                        style:
                            style ??
                            theme.typography.subtitle?.copyWith(
                              fontSize: 14,
                              color: foregroundColor.resolve(
                                HoverButton.of(context).states,
                              ),
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (showNavigation) ...[
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                icon: const Center(
                  child: Icon(FluentIcons.caret_up_solid8, size: 10),
                ),
                onPressed: onPrevious,
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                icon: const Center(
                  child: Icon(FluentIcons.caret_down_solid8, size: 10),
                ),
                onPressed: onNext,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A stateless widget that represents a single calendar item (month or year)
/// in a calendar view.
///
/// The [_CalendarItem] displays [content] in a styled [Button] with
/// customizable:
///
///   * Shape via [shape]
///   * Fill color via [fillColor]
///   * Disabled state via [isDisabled]
///   * Filled state via [isFilled]
///   * Optional group label via [groupLabel]
///
/// Triggers [onTapped] callback when pressed, unless disabled.
///
/// Used internally by month/year selection views in the calendar
class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.content,
    required this.isDisabled,
    required this.onTapped,
    this.shape,
    this.fillColor,
    this.isFilled = false,
    this.groupLabel,
  });

  final String content;
  final bool isDisabled;
  final bool isFilled;
  final String? groupLabel;
  final VoidCallback onTapped;
  final Color? fillColor;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Center(
      child: Button(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(shape ?? const CircleBorder()),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (isFilled) {
              return FilledButton.backgroundColor(theme, states);
            } else {
              return ButtonThemeData.uncheckedInputColor(
                theme,
                states,
                transparentWhenNone: true,
              );
            }
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (isDisabled) {
              return theme.resources.textFillColorDisabled;
            } else if (isFilled) {
              return theme.resources.textOnAccentFillColorPrimary;
            }
            return theme.resources.textFillColorPrimary;
          }),
        ),
        onPressed: isDisabled ? null : onTapped,
        child: SizedBox.square(
          dimension: 54,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (groupLabel != null)
                Positioned(
                  top: 0,
                  child: Text(groupLabel!, style: const TextStyle(fontSize: 8)),
                ),
              Padding(padding: const EdgeInsets.all(4.0), child: Text(content)),
            ],
          ),
        ),
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

  /// Whether this day is disabled(visually) due to being outside the allowed date range.
  final bool isOutOfScope;

  /// Whether this day is disabled and cannot be selected.
  final bool isBlackout;

  /// Whether the day item should be filled with the selection color.
  final bool isFilled;

  /// Callback invoked when the day item is tapped.
  /// Receives the [day] as a parameter.
  final ValueChanged<DateTime> onDayTapped;

  /// The color used for selection and highlighting.
  /// If null, the default brush for the theme's accent color is used.
  final Color? selectionColor;

  final ShapeBorder? shape;

  /// Whether to show the month label above the day number for the first day of each month.
  final bool showGroupLabel;

  final Locale locale;

  const _CalendarDayItem({
    required this.day,
    required this.isSelected,
    required this.isInRange,
    required this.isOutOfScope,
    required this.isBlackout,
    required this.onDayTapped,
    required this.locale,
    this.shape,
    this.selectionColor,
    this.isFilled = false,
    required this.showGroupLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color = theme.accentColor.defaultBrushFor(theme.brightness);
    final Color borderColor = isSelected
        ? selectionColor ?? color
        : isBlackout
        ? theme.resources.accentFillColorDisabled
        : theme.resources.subtleFillColorTransparent;

    final borderWidth = isSelected ? 1.0 : 0.0;

    return Container(
      constraints: BoxConstraints.tight(const Size.square(40)),
      decoration: ShapeDecoration(
        shape:
            shape ??
            CircleBorder(
              side: BorderSide(width: borderWidth, color: borderColor),
            ),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Button(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(
            kDefaultButtonPadding - EdgeInsetsDirectional.all(borderWidth * 2),
          ),
          shape: WidgetStateProperty.resolveWith((states) {
            return const CircleBorder(side: BorderSide.none);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (isFilled) return FilledButton.backgroundColor(theme, states);
            if (isInRange) return color.withAlpha(50);
            if (isBlackout) return Colors.transparent;
            if (states.contains(WidgetState.hovered)) {
              return selectionColor?.withAlpha(20) ??
                  theme.resources.subtleFillColorSecondary;
            }

            return theme.resources.subtleFillColorTransparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (isFilled) {
              return theme.resources.textOnAccentFillColorPrimary;
            } else if (isBlackout) {
              return theme.resources.textFillColorPrimary;
            } else if (isOutOfScope) {
              return theme.resources.textFillColorSecondary;
            }
            return isSelected ? color : theme.resources.textFillColorPrimary;
          }),
        ),
        onPressed: isBlackout ? null : () => onDayTapped(day),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (showGroupLabel)
              Positioned(
                top: -6,
                child: Text(
                  DateFormat.MMM(locale.toString()).format(day),
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            Text('${day.day}'),
          ],
        ),
      ),
    );
  }
}
