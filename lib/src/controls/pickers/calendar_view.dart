import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

part 'calendar_date_picker.dart';

/// A callback that returns whether a date is blacked out.
typedef CalendarViewBlackoutRule = bool Function(DateTime date);

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
@immutable
class CalendarSelectionData {
  /// The list of selected dates.
  final List<DateTime> selectedDates;

  /// The start date of the selection range, if applicable.
  final DateTime? startDate;

  /// The end date of the selection range, if applicable.
  final DateTime? endDate;

  /// Creates a calendar selection data.
  ///
  /// If both the [startDate] and [endDate] are provided, the [startDate] must
  /// be before the [endDate].
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
///  * [CalendarDatePicker], which provides a more compact date selection interface.
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

  /// The minimum date that can be selected. Dates before this will be
  /// considered invalid for selection.
  final DateTime? minDate;

  /// The maximum date that can be selected. Dates after this will be
  /// considered invalid for selection.
  final DateTime? maxDate;

  /// The maximum date that can be displayed in the calendar.
  ///
  /// This date must be at least 10 years after [displayDateStart] if both are provided.
  final DateTime? displayDateEnd;

  /// The minimum date that can be displayed in the calendar.
  /// This date must be at least 10 years before [displayDateEnd] if both are provided.
  final DateTime? displayDateStart;

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
  final CalendarViewBlackoutRule? blackoutRule;

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

  /// The scroll behavior to use for the calendar view.
  /// If null, a default scroll behavior will be used with disabled scrollbars
  /// and bouncing scroll physics.
  final ScrollBehavior? scrollBehavior;

  /// Creates a windows-styled [CalendarView].
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
    this.displayDateEnd,
    this.displayDateStart,
    this.scrollBehavior,
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
       ),
       assert(
         displayDateEnd == null ||
             displayDateStart == null ||
             displayDateEnd.year - displayDateStart.year >= 10,
         'displayDateEnd must be at least 10 years after displayDateStart if both are provided.',
       ),
       assert(
         displayDateEnd == null ||
             displayDateStart == null ||
             (displayDateStart.isBefore(DateTime.now()) &&
                 displayDateEnd.isAfter(DateTime.now())) ||
             (initialStart != null &&
                 initialStart.isAfter(displayDateStart) &&
                 initialStart.isBefore(displayDateEnd)),
         'initialStart must be within scroll dates range if the current date is not inside.',
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

  late ScrollBehavior _scrollBehavior;

  /// The minimum year that can be displayed in the calendar.
  /// Defaults to current year minus half of [_defaultDisplayedYearCount].
  late int _minDisplayedYear;

  /// The maximum year that can be displayed in the calendar.
  /// Defaults to current year plus half of [_defaultDisplayedYearCount].
  late int _maxDisplayedYear;

  /// Describes the date that is currently visible in the calendar when
  /// scrolling.
  // DateTime? _scrollDate;
  final _scrollDate = ValueNotifier<DateTime?>(null);

  static const double _rowHeight = 40;
  static const double _yearRowHeight = 70;

  /// The default number of years to be displayed in the calendar
  static const int _defaultDisplayedYearCount = 200;

  /// The currently visible date in the calendar.
  DateTime get visibleDate {
    return _scrollDate.value ?? _anchorMonth;
  }

  /// The current visible decade in the calendar.
  DateTime get visibleDecade {
    final minYear = widget.displayDateStart?.year;
    final maxYear = widget.displayDateEnd?.year;
    var startYear = _anchorMonth.year - (_anchorMonth.year % 10);

    if (minYear != null && startYear < minYear) {
      startYear = minYear;
    }
    if (maxYear != null && startYear > maxYear - 9) {
      startYear = maxYear - 9;
    }
    return DateTime(startYear);
  }

  @override
  void initState() {
    super.initState();
    _scrollBehavior =
        widget.scrollBehavior ??
        const ScrollBehavior().copyWith(
          scrollbars: false,
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
        );

    if (widget.selectionMode == CalendarViewSelectionMode.multiple) {
      if (_selectedStart != null) _selectedMultiple.add(_selectedStart!);
      if (_selectedEnd != null) _selectedMultiple.add(_selectedEnd!);
    }
    final currentDate = DateTime.now();
    final anchor = widget.initialStart ?? currentDate;
    _anchorMonth = DateTime(anchor.year, anchor.month);

    _monthScrollController.addListener(_monthScrollListener);
    _yearScrollController.addListener(_yearScrollListener);
    _decadeScrollController.addListener(_decadeScrollListener);

    _minDisplayedYear =
        widget.displayDateStart?.year ??
        currentDate.year - (_defaultDisplayedYearCount ~/ 2);
    _maxDisplayedYear =
        widget.displayDateEnd?.year ??
        currentDate.year + (_defaultDisplayedYearCount ~/ 2);
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

    // Update the min/max display years if the date range changes
    if (widget.displayDateStart != oldWidget.displayDateStart ||
        widget.displayDateEnd != oldWidget.displayDateEnd) {
      final currentDate = DateTime.now();
      _minDisplayedYear =
          widget.displayDateStart?.year ??
          currentDate.year - (_defaultDisplayedYearCount ~/ 2);
      _maxDisplayedYear =
          widget.displayDateEnd?.year ??
          currentDate.year + (_defaultDisplayedYearCount ~/ 2);

      // Clamp anchorMonth to new range if needed
      final minDate = widget.displayDateStart ?? DateTime(_minDisplayedYear);
      final maxDate =
          widget.displayDateEnd ?? DateTime(_maxDisplayedYear, 12, 31);
      if (_anchorMonth.isBefore(minDate)) {
        _anchorMonth = minDate;
      } else if (_anchorMonth.isAfter(maxDate)) {
        _anchorMonth = DateTime(maxDate.year, maxDate.month);
      }
    }

    // Handle selection mode changes by resetting selection state
    if (widget.selectionMode != oldWidget.selectionMode) {
      _selectedStart = widget.initialStart;
      _selectedEnd = widget.selectionMode == CalendarViewSelectionMode.range
          ? widget.initialEnd
          : null;
      _selectedMultiple.clear();

      if (widget.selectionMode == CalendarViewSelectionMode.multiple &&
          _selectedStart != null) {
        _selectedMultiple.add(_selectedStart!);
      }
      _notifySelectionChanged();
      return;
    }

    // Update selection when initial dates change
    if (widget.initialStart != oldWidget.initialStart ||
        (widget.selectionMode == CalendarViewSelectionMode.range &&
            widget.initialEnd != oldWidget.initialEnd)) {
      _selectedStart = widget.initialStart;
      if (widget.selectionMode == CalendarViewSelectionMode.range) {
        _selectedEnd = widget.initialEnd;
      }
      if (widget.selectionMode == CalendarViewSelectionMode.multiple) {
        _selectedMultiple.clear();
        if (_selectedStart != null) {
          _selectedMultiple.add(_selectedStart!);
        }
      }
      _notifySelectionChanged();
    }

    // Validate and update selections when min/max dates change
    if (widget.minDate != oldWidget.minDate ||
        widget.maxDate != oldWidget.maxDate) {
      final wasStartInvalid =
          _selectedStart != null && !_isDateWithinBounds(_selectedStart!);
      final wasEndInvalid =
          _selectedEnd != null && !_isDateWithinBounds(_selectedEnd!);
      final originalCount = _selectedMultiple.length;
      _selectedMultiple.removeWhere((date) => !_isDateWithinBounds(date));
      final wasMultipleInvalid = originalCount != _selectedMultiple.length;

      if (wasStartInvalid) _selectedStart = null;
      if (wasEndInvalid) _selectedEnd = null;

      if (wasStartInvalid || wasEndInvalid || wasMultipleInvalid) {
        _notifySelectionChanged();
      }
    }

    // Update display mode if it changed and differs from current
    if (widget.initialDisplayMode != oldWidget.initialDisplayMode &&
        widget.initialDisplayMode != _displayMode) {
      _displayMode = widget.initialDisplayMode;
    }
  }

  /// Helper method to check if a date is within the min/max selection bounds.
  bool _isDateWithinBounds(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) {
      return false;
    }
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) {
      return false;
    }
    return true;
  }

  void _notifySelectionChanged() {
    if (widget.onSelectionChanged == null) return;

    final data = switch (widget.selectionMode) {
      CalendarViewSelectionMode.none => CalendarSelectionData(
        selectedDates: const [],
      ),
      CalendarViewSelectionMode.single => CalendarSelectionData(
        selectedDates: _selectedStart != null ? [_selectedStart!] : [],
        startDate: _selectedStart,
      ),
      CalendarViewSelectionMode.range => CalendarSelectionData(
        selectedDates: [
          if (_selectedStart != null) _selectedStart!,
          if (_selectedEnd != null) _selectedEnd!,
        ],
        startDate: _selectedStart,
        endDate: _selectedEnd,
      ),
      CalendarViewSelectionMode.multiple => CalendarSelectionData(
        selectedDates: List.unmodifiable(_selectedMultiple),
        startDate: _selectedMultiple.isNotEmpty
            ? _selectedMultiple.first
            : null,
        endDate: _selectedMultiple.length > 1 ? _selectedMultiple.last : null,
      ),
    };
    widget.onSelectionChanged?.call(data);
  }

  /// Determines whether the scroll date should be updated based on the new
  /// date. This avoids unnecessary rebuilds while scrolling.
  bool _shouldUpdateDate(DateTime? newDate) {
    if (newDate == null) return false;
    if (_displayMode == CalendarViewDisplayMode.month) {
      return !DateUtils.isSameMonth(newDate, visibleDate);
    } else if (_displayMode == CalendarViewDisplayMode.year) {
      return newDate.year != visibleDate.year;
    } else if (_displayMode == CalendarViewDisplayMode.decade) {
      return newDate.year ~/ 10 != visibleDate.year ~/ 10;
    }
    return false;
  }

  void _monthScrollListener() {
    final pixels = _monthScrollController.position.pixels;
    final rowIndex = (pixels / _rowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.month) {
      final newScrollDate = _daysFromAnchor(rowIndex * 7 + 10);
      if (_shouldUpdateDate(newScrollDate)) {
        // todo(kv): work pretty well when adding 10 days.
        //  It is maybe due because of bug of the duplicated week in June.
        _scrollDate.value = newScrollDate;
      }
    }
  }

  void _yearScrollListener() {
    final pixels = _yearScrollController.position.pixels;
    final rowIndex = (pixels / _yearRowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.year) {
      final page = (rowIndex / 4).round();
      final newScrollDate = _yearForPage(page);
      if (_shouldUpdateDate(newScrollDate)) {
        _scrollDate.value = newScrollDate;
      }
    }
  }

  void _decadeScrollListener() {
    final pixels = _decadeScrollController.position.pixels;
    final rowIndex = (pixels / _yearRowHeight).round();
    if (_displayMode == CalendarViewDisplayMode.decade) {
      final page = (rowIndex / 2.5).round();
      final newScrollDate = _decadeForPage(page);
      if (_shouldUpdateDate(newScrollDate)) {
        _scrollDate.value = _decadeForPage(page);
      }
    }
  }

  DateTime _daysFromAnchor(int days) {
    return DateTime(
      _anchorMonth.year,
      _anchorMonth.month,
    ).add(Duration(days: days));
  }

  DateTime _yearForPage(int page) {
    return DateTime(_anchorMonth.year + page, _anchorMonth.month);
  }

  DateTime _decadeForPage(int page) {
    return DateTime(visibleDecade.year + page * 10);
  }

  /// Navigates to the specified month in the calendar view.
  void navigateToMonth(DateTime date) {
    setState(() {
      _scrollDate.value = null;
      _anchorMonth = DateTime(date.year, date.month);
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
    final offsetDate = DateTime(visibleDate.year, visibleDate.month + offset);
    navigateToMonth(offsetDate);
  }

  /// Navigates to the specified year in the calendar view.
  void navigateToYear(DateTime date) {
    setState(() {
      _scrollDate.value = null;
      _anchorMonth = DateTime(date.year, date.month);
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

    if (widget.selectionMode == CalendarViewSelectionMode.none) {
      return;
    }

    setState(() {
      switch (widget.selectionMode) {
        case CalendarViewSelectionMode.single:
          _selectedStart = DateUtils.isSameDay(_selectedStart, day)
              ? null
              : day;
          _selectedEnd = null;
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
          }
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
        default:
          return;
      }
    });
    _notifySelectionChanged();
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
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(1),
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
    return ValueListenableBuilder(
      valueListenable: _scrollDate,
      builder: (context, _, _) {
        final locale = widget.locale ?? Localizations.localeOf(context);

        final isBlackout =
            !_isDateWithinBounds(day) ||
            (widget.blackoutRule?.call(day) ?? false);
        final isCurrentMonth = DateUtils.isSameMonth(day, visibleDate);
        final isFirstMonthDay = DateUtils.isSameDay(
          day,
          DateTime(day.year, day.month),
        );
        final isSelected =
            widget.selectionMode == CalendarViewSelectionMode.single
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
            widget.isTodayHighlighted &&
            DateUtils.isSameDay(day, DateTime.now());

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
      },
    );
  }

  Widget _buildHeader() {
    VoidCallback? onTap;
    VoidCallback? onNext;
    VoidCallback? onPrevious;
    final minDate = widget.displayDateStart ?? DateTime(_minDisplayedYear);
    final maxDate = widget.displayDateEnd ?? DateTime(_maxDisplayedYear);

    switch (_displayMode) {
      case CalendarViewDisplayMode.month:
        onTap = () {
          setState(() {
            stepYear();
            _displayMode = CalendarViewDisplayMode.year;
          });
        };
        onNext = DateUtils.isSameMonth(maxDate, visibleDate)
            ? null
            : () => stepMonth(offset: 1);
        onPrevious = DateUtils.isSameMonth(minDate, visibleDate)
            ? null
            : () => stepMonth(offset: -1);
      case CalendarViewDisplayMode.year:
        onTap = () =>
            setState(() => _displayMode = CalendarViewDisplayMode.decade);
        onNext = maxDate.year <= visibleDate.year
            ? null
            : () => stepYear(offset: 1);
        onPrevious = minDate.year >= visibleDate.year
            ? null
            : () => stepYear(offset: -1);
      case CalendarViewDisplayMode.decade:
        break;
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 8,
          top: 8,
          bottom: 4,
        ),
        child: ValueListenableBuilder(
          valueListenable: _scrollDate,
          builder: (context, value, _) => _CalendarHeader(
            date: visibleDate,
            displayMode: _displayMode,
            onNext: onNext,
            onPrevious: onPrevious,
            onTap: _displayMode == CalendarViewDisplayMode.decade
                ? null
                : onTap,
            style: widget.headerStyle,
            locale: widget.locale,
            showNavigation: _displayMode != CalendarViewDisplayMode.decade,
          ),
        ),
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
    final row = index ~/ crossAxisCount;
    final col = index % crossAxisCount;

    // Calculate the index as if the items in the row were reversed.
    // This finds the "mirror" index within the same row.
    final swappedIndexInRow = crossAxisCount - 1 - col;
    final swappedBuilderIndex = (row * crossAxisCount) + swappedIndexInRow;

    // Convert the 0-based swapped index to the final negative display index.
    return -swappedBuilderIndex - 1;
  }

  Widget _buildMonthView() {
    return Column(
      key: const ValueKey('month_view'),
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsetsDirectional.zero),
        ),
        const SizedBox(height: 4),
        _buildWeekDays(context),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          height: widget.weeksPerView * _rowHeight,
          child: Builder(
            builder: (context) {
              final forwardListKey = UniqueKey();

              // The offset describes how many days from the first day of the
              // week. This align the first week of the month correctly.
              final offset = (_anchorMonth.weekday - firstDayOfWeek + 7) % 7;

              const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: _rowHeight,
              );

              final firstMonth = widget.displayDateStart?.month ?? 1;
              final reverseGridMonthCount =
                  (_anchorMonth.year - _minDisplayedYear) * 12 -
                  firstMonth +
                  _anchorMonth.month;
              final reverseGridCount =
                  reverseGridMonthCount *
                  4; // Assuming each month have 04 weeks
              final reverseGrid = SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final negativeIndex = _getNegativeIndex(index, 7) - offset;
                  final day = _anchorMonth.add(Duration(days: negativeIndex));

                  if (day.isAfter(
                        widget.displayDateEnd ?? DateTime(_maxDisplayedYear),
                      ) ||
                      day.isBefore(
                        widget.displayDateStart ?? DateTime(_minDisplayedYear),
                      )) {
                    return const SizedBox.shrink();
                  }

                  return _buildDayItem(day);
                }, childCount: reverseGridCount),
              );

              final lastMonth = widget.displayDateEnd?.month ?? 12;
              final forwardGridMonthCount =
                  (_maxDisplayedYear - _anchorMonth.year) * 12 +
                  lastMonth -
                  _anchorMonth.month +
                  1;
              final forwardGridCount = forwardGridMonthCount * 4 + 1;
              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final day = _anchorMonth.add(Duration(days: index - offset));
                  if (day.isAfter(
                        widget.displayDateEnd ?? DateTime(_maxDisplayedYear),
                      ) ||
                      day.isBefore(
                        widget.displayDateStart ?? DateTime(_minDisplayedYear),
                      )) {
                    return const SizedBox.shrink();
                  }

                  return _buildDayItem(day);
                }, childCount: forwardGridCount),
              );

              return CustomScrollView(
                controller: _monthScrollController,
                scrollBehavior: _scrollBehavior,
                semanticChildCount: reverseGridCount + forwardGridCount,
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
      key: const ValueKey('year_view'),
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsetsDirectional.zero),
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

              final reverseGridCount =
                  (_anchorMonth.year - _minDisplayedYear) * 12;

              final reverseGrid = SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final nIndex = _getNegativeIndex(index, 4);
                  final year = _anchorMonth.year - 1 + (nIndex ~/ 13);
                  final monthNumber = (nIndex % 12) + 1;

                  final isMonthVisible =
                      !(widget.displayDateStart != null) ||
                      DateTime(
                        year,
                        monthNumber,
                      ).isAfter(widget.displayDateStart!);

                  if (!isMonthVisible) {
                    return SizedBox.shrink(key: ValueKey(year));
                  }

                  return _buildYearItem(year, monthNumber);
                }, childCount: reverseGridCount),
              );

              final lastMonth = widget.displayDateEnd?.month ?? 12;
              final forwardGridCount =
                  (_maxDisplayedYear - _anchorMonth.year) * 12 + lastMonth;
              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final year = _anchorMonth.year + (index ~/ 12);
                  final monthNumber = (index % 12) + 1;

                  return _buildYearItem(year, monthNumber);
                }, childCount: forwardGridCount),
              );

              return CustomScrollView(
                controller: _yearScrollController,
                scrollBehavior: _scrollBehavior,
                semanticChildCount: reverseGridCount + forwardGridCount,
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
    return ValueListenableBuilder(
      valueListenable: _scrollDate,
      builder: (context, _, _) {
        final locale = widget.locale ?? Localizations.localeOf(context);

        final isCurrentYear = visibleDate.year == year;
        final month = isCurrentYear
            ? DateTime(year, monthNumber)
            : DateTime(year + (monthNumber ~/ 12), monthNumber % 12);
        final isDisabled = !_isDateWithinBounds(month);
        final isFilled =
            isCurrentYear && DateUtils.isSameMonth(month, DateTime.now());
        final showGroupLabel = widget.isGroupLabelVisible && month.month == 1;
        return _CalendarItem(
          content: DateFormat.MMM(locale.toString()).format(month),
          isDisabled: isDisabled,
          isFilled: isFilled,
          fillColor: widget.selectionColor,
          isOutOfScope: !widget.isOutOfScopeEnabled && !isCurrentYear,
          shape: widget.dayItemShape,
          groupLabel: showGroupLabel
              ? DateFormat.y(locale.toString()).format(month)
              : null,
          onTapped: () => navigateToMonth(month),
        );
      },
    );
  }

  Widget _buildDecadeView() {
    return Column(
      key: const ValueKey('decades_view'),
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildHeader(),
        const Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsetsDirectional.zero),
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
                  final year = visibleDecade.year + nIndex;

                  // If the year is not within the display range, we need to skip it.
                  // This ensures the grid structure is maintained due to the
                  // nature of the reverse grid.
                  final isYearDisplayed =
                      year >= _minDisplayedYear && year <= _maxDisplayedYear;
                  if (!isYearDisplayed) {
                    final yearsInCurrentRow = [
                      visibleDecade.year + nIndex,
                      visibleDecade.year + nIndex + 1,
                      visibleDecade.year + nIndex + 2,
                      visibleDecade.year + nIndex + 3,
                    ];

                    if (!yearsInCurrentRow.any((y) => y >= _minDisplayedYear)) {
                      return null;
                    }

                    return SizedBox.shrink(key: ValueKey(year));
                  }

                  return KeyedSubtree(
                    key: ValueKey(year),
                    child: _buildDecadeItem(year),
                  );
                }),
              );

              final forwardGrid = SliverGrid(
                key: forwardListKey,
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final year = visibleDecade.year + index;

                  return _buildDecadeItem(year);
                }, childCount: _maxDisplayedYear - visibleDecade.year + 1),
              );

              return CustomScrollView(
                controller: _decadeScrollController,
                scrollBehavior: _scrollBehavior,
                semanticChildCount: _maxDisplayedYear - _minDisplayedYear,
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
    return ValueListenableBuilder(
      valueListenable: _scrollDate,
      builder: (context, _, _) {
        final isCurrentYear = year == DateTime.now().year;
        final isDisabled =
            (widget.minDate != null &&
                DateTime(year).isBefore(widget.minDate!)) ||
            (widget.maxDate != null &&
                DateTime(year, 12, 31).isAfter(widget.maxDate!));

        final currentDecadeStart = (visibleDate.year ~/ 10) * 10;
        final currentDecadeEnd = currentDecadeStart + 9;
        final isOutOfScope =
            year < currentDecadeStart || year > currentDecadeEnd;
        return _CalendarItem(
          content: year.toString(),
          isOutOfScope: !widget.isOutOfScopeEnabled && isOutOfScope,
          isDisabled: isDisabled,
          onTapped: () => navigateToYear(DateTime(year)),
          fillColor: widget.selectionColor,
          isFilled: isCurrentYear,
          shape: widget.dayItemShape,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.resources.controlFillColorInputActive,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.resources.controlStrokeColorDefault,
            ),
          ),
      constraints: const BoxConstraints(maxWidth: 300, minHeight: 350),
      child: AnimatedSwitcher(
        duration: theme.fastAnimationDuration,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: switch (_displayMode) {
          CalendarViewDisplayMode.month => _buildMonthView(),
          CalendarViewDisplayMode.year => _buildYearView(),
          CalendarViewDisplayMode.decade => _buildDecadeView(),
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
      ),
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
    final label = switch (displayMode) {
      CalendarViewDisplayMode.month => DateFormat.yMMMM(
        locale.toLanguageTag(),
      ).format(date),
      CalendarViewDisplayMode.year => date.year.toString(),
      CalendarViewDisplayMode.decade =>
        '${(date.year ~/ 10) * 10} - ${(date.year ~/ 10) * 10 + 9}',
    };

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
                  child: WindowsIcon(WindowsIcons.caret_up_solid8, size: 10),
                ),
                onPressed: onPrevious,
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                icon: const Center(
                  child: WindowsIcon(WindowsIcons.caret_down_solid8, size: 10),
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
    required this.isOutOfScope,
    this.shape,
    this.fillColor,
    this.isFilled = false,
    this.groupLabel,
  });

  final String content;
  final bool isDisabled;
  final bool isOutOfScope;
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
            } else if (isOutOfScope) {
              return theme.resources.textFillColorSecondary;
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
              Padding(
                padding: const EdgeInsetsDirectional.all(4),
                child: Text(content),
              ),
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
    required this.showGroupLabel,
    this.shape,
    this.selectionColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color = theme.accentColor.defaultBrushFor(theme.brightness);
    final borderColor = isSelected
        ? selectionColor ?? color
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
      padding: EdgeInsetsDirectional.all(borderWidth),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Button(
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                kDefaultButtonPadding -
                    EdgeInsetsDirectional.all(borderWidth * 2),
              ),
              shape: WidgetStateProperty.resolveWith((states) {
                return const CircleBorder();
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (isFilled) {
                  return FilledButton.backgroundColor(theme, states);
                } else if (isBlackout) {
                  return isFilled
                      ? selectionColor ?? color
                      : Colors.transparent;
                } else if (isInRange) {
                  return color.withAlpha(50);
                } else if (states.contains(WidgetState.hovered)) {
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
                } else if (isSelected) {
                  return color;
                }
                return theme.resources.textFillColorPrimary;
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
          if (isBlackout)
            CustomPaint(
              painter: _SlashPainter(
                color: isFilled
                    ? theme.resources.textOnAccentFillColorPrimary
                    : theme.resources.controlStrongStrokeColorDefault,
              ),
            ),
        ],
      ),
    );
  }
}

/// A [CustomPainter] that draws a diagonal slash (from top-right to bottom-left)
/// with configurable color and padding. Useful for indicating disabled or unavailable
/// states in UI elements.
///
/// The slash is drawn with a fixed stroke width and rounded stroke cap.
class _SlashPainter extends CustomPainter {
  final Color color;

  _SlashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    final pad = size.width * 0.3;
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(pad, size.height - pad),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SlashPainter oldDelegate) => oldDelegate.color != color;
}
