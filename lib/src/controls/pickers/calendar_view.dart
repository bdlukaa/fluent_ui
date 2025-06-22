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
  final Color? selectionColor;

  /// The decoration for the calendar container.
  final BoxDecoration? decoration;

  /// The shape of the day item buttons.
  final WidgetStateProperty<ShapeBorder>? dayItemShape;

  /// The initial display mode of the calendar view.
  ///
  /// Defaults to [CalendarViewDisplayMode.month].
  final CalendarViewDisplayMode initialDisplayMode;

  /// The selection mode for the calendar view.
  ///
  /// Defaults to [CalendarViewSelectionMode.single].
  final CalendarViewSelectionMode selectionMode;

  /// Whether to highlight today's date.
  final bool isTodayHighlighted;

  /// This determines how many weeks are shown in the month view.
  ///
  /// It can be set to a value between 4 and 8, with the default being 6.
  final int weeksPerView;

  /// Whether to enable selection of out-of-scope dates.
  ///
  /// If enabled, users can select dates that are outside the defined[minDate]
  /// and [maxDate].
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
  const CalendarView({
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
    this.isTodayHighlighted = true,
    this.decoration,
    this.headerStyle,
    this.weeksPerView = 6,
    this.isOutOfScopeEnabled = false,
    this.locale,
    this.isGroupLabelVisible = true,
  }) : assert(weeksPerView >= 4 && weeksPerView <= 8);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const int _yearsToShow = 200;
  static const int _monthsToShow = _yearsToShow * 12 + 1;
  static const int _initialPage = _monthsToShow ~/ 2;
  static const int _initialYearPage = _yearsToShow ~/ 2;

  late final DateTime _anchorMonth;
  late int _currentPage;
  late DateTime _visibleMonth;
  late CalendarViewDisplayMode _displayMode;
  DateTime? selectedStart;
  DateTime? selectedEnd;
  final selectedMultiple = <DateTime>[];

  late PageController _pageController;

  late int _currentYearPage;
  late DateTime _visibleYear;
  late PageController _yearPageController;

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
    _displayMode = widget.initialDisplayMode;
    final anchor = widget.initialStart ?? DateTime.now();
    _anchorMonth = DateTime(anchor.year, anchor.month, 1);

    _currentPage = _initialPage;
    _visibleMonth = _monthForPage(_currentPage);
    _pageController = PageController(initialPage: _currentPage);

    _currentYearPage = _initialYearPage;
    _visibleYear = DateTime(
      _anchorMonth.year + (_currentYearPage - _initialYearPage),
      1,
      1,
    );
    _yearPageController = PageController(initialPage: _currentYearPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _yearPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectionMode != oldWidget.selectionMode) {
      // Reset selection state if the selection mode changes
      selectedStart = widget.initialStart;
      selectedEnd = widget.selectionMode == CalendarViewSelectionMode.range
          ? widget.initialEnd
          : null;
      selectedMultiple.clear();
      if (selectedStart != null) selectedMultiple.add(selectedStart!);
      if (selectedEnd != null) selectedMultiple.add(selectedEnd!);
    }
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
        widget.onSelectionChanged?.call(
          CalendarSelectionData(
            selectedDates: selectedStart != null ? [selectedStart!] : [],
            startDate: selectedStart,
            endDate: null,
          ),
        );
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
          // widget.onSelectionChanged?.call(selectedStart!, selectedEnd!);
          widget.onSelectionChanged?.call(
            CalendarSelectionData(
              selectedDates: [?selectedStart, ?selectedEnd],
              startDate: selectedStart,
              endDate: selectedEnd,
            ),
          );
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
          CalendarSelectionData(
            selectedDates: List.unmodifiable(selectedMultiple),
            startDate: selectedMultiple.isNotEmpty
                ? selectedMultiple.first
                : null,
            endDate: selectedMultiple.length > 1 ? selectedMultiple.last : null,
          ),
        );
      }
    });
  }

  List<Widget> _buildWeekDays(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final symbols = DateFormat.E(
      locale.toString(),
    ).dateSymbols.STANDALONESHORTWEEKDAYS;
    return List.generate(7, (i) {
      final weekdayIndex = i % 7;
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Text(
              symbols[weekdayIndex == 7 ? 0 : weekdayIndex].titleCase,
              style: FluentTheme.of(
                context,
              ).typography.body?.copyWith(fontWeight: FontWeight.w500),
            ),
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
      final days = <Widget>[];
      for (int d = 0; d < 7; d++) {
        final day = firstDay.add(Duration(days: week * 7 + d));
        final isBlackout =
            (widget.minDate != null && day.isBefore(widget.minDate!)) ||
            (widget.maxDate != null && day.isAfter(widget.maxDate!));
        final isCurrentMonth = DateUtils.isSameMonth(day, currentMonth);
        final isFirstMonthDay = DateUtils.isSameDay(
          day,
          DateTime(day.year, day.month),
        );
        final isSelected =
            widget.selectionMode == CalendarViewSelectionMode.single
            ? _isSameDay(day, selectedStart)
            : widget.selectionMode == CalendarViewSelectionMode.range
            ? (_isSameDay(day, selectedStart) || _isSameDay(day, selectedEnd))
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
              isOutOfScope: !widget.isOutOfScopeEnabled && !isCurrentMonth,
              isBlackout: isBlackout,
              onDayTapped: (date) => _onDayTapped(date, !isBlackout),
              shape: widget.dayItemShape,
              selectionColor: widget.selectionColor,
              isFilled: isToday,
              showGroupLabel: widget.isGroupLabelVisible && isFirstMonthDay,
              locale: widget.locale,
            ),
          ),
        );
      }
      rows.add(Row(children: days));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
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

  void _navigateYear(int offset) {
    final newPage = _currentYearPage + offset;
    if (newPage < 0 || newPage >= _yearsToShow) return;
    _yearPageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Widget _buildHeader() {
    VoidCallback? onTap, onNext, onPrevious;

    switch (_displayMode) {
      case CalendarViewDisplayMode.month:
        onTap = () {
          final yearPage =
              _initialYearPage + (_visibleMonth.year - _anchorMonth.year);
          setState(() {
            _currentYearPage = yearPage;
            _visibleYear = DateTime(_visibleMonth.year, 1, 1);
            _displayMode = CalendarViewDisplayMode.year;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_yearPageController.hasClients) {
              _yearPageController.jumpToPage(yearPage);
            }
          });
        };
        onNext = _currentPage + 1 >= _monthsToShow
            ? null
            : () => _navigateMonth(1);
        onPrevious = _currentPage - 1 < 0 ? null : () => _navigateMonth(-1);
        break;
      case CalendarViewDisplayMode.year:
        onTap = () =>
            setState(() => _displayMode = CalendarViewDisplayMode.decade);
        onNext = _currentYearPage + 1 >= _yearsToShow
            ? null
            : () => _navigateYear(1);
        onPrevious = _currentYearPage - 1 < 0 ? null : () => _navigateYear(-1);
        break;
      case CalendarViewDisplayMode.decade:
        break;
    }

    return _CalendarHeader(
      date: _displayMode == CalendarViewDisplayMode.year
          ? _visibleYear
          : _visibleMonth,
      displayMode: _displayMode,
      onNext: onNext,
      onPrevious: onPrevious,
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
          height: widget.weeksPerView * 40.0,
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
          height: 4 * 68.0,
          child: PageView.builder(
            controller: _yearPageController,
            scrollDirection: Axis.vertical,
            physics: const RangeMaintainingScrollPhysics(),
            pageSnapping: false,
            itemCount: _yearsToShow,
            onPageChanged: (index) {
              setState(() {
                _visibleYear = DateTime(
                  _anchorMonth.year + (index - _initialYearPage),
                  1,
                  1,
                );
                _currentYearPage = index;
              });
            },
            itemBuilder: (context, index) {
              final year = _visibleYear.year;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.3,
                ),
                itemCount: 16,
                itemBuilder: (context, i) {
                  final monthNumber = i + 1;
                  final isValidMonth = monthNumber >= 1 && monthNumber <= 12;
                  final month = isValidMonth
                      ? DateTime(year, monthNumber)
                      : DateTime(year + (monthNumber ~/ 12), monthNumber % 12);
                  final isDisabled =
                      !isValidMonth ||
                      (widget.minDate != null &&
                          month.isBefore(widget.minDate!)) ||
                      (widget.maxDate != null &&
                          month.isAfter(widget.maxDate!));
                  final isFilled =
                      isValidMonth &&
                      DateTime.now().year == year &&
                      DateTime.now().month == monthNumber;
                  return _CalendarItem(
                    content: DateFormat.MMM(
                      locale.toString(),
                    ).format(month).titleCase,
                    isDisabled: isDisabled,
                    isFilled: isFilled,
                    fillColor: widget.selectionColor,
                    shape: widget.dayItemShape,
                    groupLabel: month.month == 1
                        ? DateFormat.y(locale.toString()).format(month)
                        : null,
                    onTapped: () {
                      setState(() {
                        _visibleMonth = month;
                        _currentPage =
                            _initialPage +
                            (month.year - _anchorMonth.year) * 12 +
                            (month.month - _anchorMonth.month);
                        _displayMode = CalendarViewDisplayMode.month;
                      });

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(_currentPage);
                        }
                      });
                    },
                  );
                },
              );
            },
          ),
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
            final isDisabled =
                (widget.minDate != null &&
                    DateTime(y).isBefore(widget.minDate!)) ||
                (widget.maxDate != null &&
                    DateTime(y, 12, 31).isAfter(widget.maxDate!));
            return _CalendarItem(
              content: y.toString(),
              isDisabled:
                  isDisabled || y == startYear - 1 || y >= startYear + 10,
              onTapped: () => setState(() {
                _visibleYear = _visibleMonth = DateTime(y, 1, 1);
                _displayMode = CalendarViewDisplayMode.year;
              }),
              fillColor: widget.selectionColor,
              isFilled: isCurrentYear,
              shape: widget.dayItemShape,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final defaultCalendarDecoration = BoxDecoration(
      color: theme.resources.controlFillColorInputActive,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        width: 0.15,
        color: theme.resources.controlStrokeColorDefault,
      ),
    );

    return Container(
      decoration: widget.decoration ?? defaultCalendarDecoration,
      padding: const EdgeInsets.all(8),
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
    final fLocale = locale ?? Localizations.localeOf(context);
    String label;

    switch (displayMode) {
      case CalendarViewDisplayMode.month:
        label = DateFormat.yMMMM(
          fLocale.toLanguageTag(),
        ).format(date).titleCase;
        break;
      case CalendarViewDisplayMode.year:
        label = date.year.toString();
        break;
      case CalendarViewDisplayMode.decade:
        final startYear = (date.year ~/ 10) * 10;
        label = '$startYear - ${startYear + 9}';
        break;
    }

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
                  Text(
                    label,
                    style:
                        style ??
                        theme.typography.subtitle?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          if (showNavigation) ...[
            IconButton(
              icon: const Center(
                child: Icon(FluentIcons.caret_up_solid8, size: 10),
              ),
              onPressed: onPrevious,
            ),
            IconButton(
              icon: const Center(
                child: Icon(FluentIcons.caret_down_solid8, size: 10),
              ),
              onPressed: onNext,
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
  final WidgetStateProperty<ShapeBorder>? shape;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Center(
      child: Button(
        style: ButtonStyle(
          shape: shape ?? const WidgetStatePropertyAll(CircleBorder()),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (groupLabel != null)
                Positioned(
                  top: -6,
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

  /// The shape of the day item button.
  /// If null, a circular shape is used by default.
  final WidgetStateProperty<ShapeBorder>? shape;

  /// Whether to show the month label above the day number for the first day of each month.
  final bool showGroupLabel;

  /// DateTime locale
  final Locale? locale;

  const _CalendarDayItem({
    required this.day,
    required this.isSelected,
    required this.isInRange,
    required this.isOutOfScope,
    required this.isBlackout,
    required this.onDayTapped,
    this.shape,
    this.selectionColor,
    this.isFilled = false,
    required this.showGroupLabel,
    this.locale,
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

    return Button(
      style: ButtonStyle(
        shape:
            shape ??
            WidgetStateProperty.resolveWith((states) {
              return CircleBorder(
                side: BorderSide(width: 1, color: borderColor),
              );
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
          if (isBlackout) {
            return theme.resources.textFillColorPrimary;
          } else if (isOutOfScope) {
            return theme.resources.textFillColorSecondary;
          } else if (isFilled) {
            return theme.resources.textOnAccentFillColorPrimary;
          }
          return isSelected ? color : theme.resources.textFillColorPrimary;
        }),
      ),
      onPressed: isBlackout ? null : () => onDayTapped(day),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGroupLabel)
            Positioned(
              top: -3,
              child: Text(
                DateFormat.MMM(locale).format(day),
                style: const TextStyle(fontSize: 8),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text('${day.day}'),
          ),
        ],
      ),
    );
  }
}
