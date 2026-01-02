part of 'calendar_view.dart';

/// The calendar date picker is a drop down control that's optimized for picking
/// a single date from a calendar view where contextual information like the day
/// of the week or fullness of the calendar is important. You can modify the
/// calendar to provide additional context or to limit available dates.
///
/// ![](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/calendar-date-picker-2-views.png)
///
/// See also:
///
///  * [CalendarView], which is the base class for this control.
///  * [DatePicker], which provides a more compact date selection interface.
///  * [TimePicker], which allows users to select a time.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/calendar-date-picker>
class CalendarDatePicker extends CalendarView {
  /// Creates a fluent-styled calendar date picker.
  CalendarDatePicker({
    super.key,
    super.initialStart,
    super.initialEnd,
    super.onSelectionChanged,
    super.minDate,
    super.maxDate,
    super.dayItemShape,
    super.initialDisplayMode,
    super.selectionColor,
    super.blackoutRule,
    super.isTodayHighlighted,
    super.decoration,
    super.headerStyle,
    super.weeksPerView,
    super.yearsPerView,
    super.firstDayOfWeek,
    super.isOutOfScopeEnabled,
    super.locale,
    super.isGroupLabelVisible,
    super.displayDateEnd,
    super.displayDateStart,
    super.scrollBehavior,
    this.placeholderText,
    this.dateFormatter,
    this.placement = FlyoutPlacementMode.bottomCenter,
    this.verticalOffset,
    this.transitionBuilder,
    this.closeOnSelection = true,
  });

  /// The text that will be displayed when no date is selected.
  final String? placeholderText;

  /// The date formatter to use for displaying the selected date, if any.
  ///
  /// If not provided, [DateFormat.yMd] will be used with the current locale.
  final DateFormat? dateFormatter;

  /// The placement of the flyout.
  ///
  /// [FlyoutPlacementMode.bottomCenter] is used by default
  final FlyoutPlacementMode placement;

  /// The space between the button and the flyout.
  final double? verticalOffset;

  /// The transition animation builder.
  ///
  /// See also:
  ///
  ///  * [FlyoutTransitionBuilder], which is the signature of this property
  final FlyoutTransitionBuilder? transitionBuilder;

  /// Whether the flyout should close when a date is selected.
  ///
  /// Defaults to `true`.
  final bool closeOnSelection;

  @override
  State<CalendarView> createState() => CalendarDatePickerState();
}

class CalendarDatePickerState extends CalendarViewState {
  final _flyoutController = FlyoutController();
  // a hack to rebuild the flyout when the state changes
  // this is necessary because the flyout does not rebuild when the state changes
  final _flyoutKey = GlobalKey();

  @override
  CalendarDatePicker get widget => super.widget as CalendarDatePicker;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      _flyoutKey.currentState?.setState(() {
        // This will rebuild the flyout when the state changes.
      });
    }
  }

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  /// Shows the calendar date picker flyout.
  void show({
    bool barrierDismissible = true,
    bool dismissWithEsc = true,
    bool dismissOnPointerMoveAway = false,
  }) {
    _flyoutController.showFlyout<void>(
      barrierColor: Colors.transparent,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: widget.placement,
      ),
      additionalOffset: widget.verticalOffset ?? 8.0,
      barrierDismissible: barrierDismissible,
      dismissOnPointerMoveAway: dismissOnPointerMoveAway,
      dismissWithEsc: dismissWithEsc,
      transitionBuilder: widget.transitionBuilder,
      builder: (context) {
        final theme = FluentTheme.of(context);
        return StatefulBuilder(
          key: _flyoutKey,
          builder: (context, setState) {
            return Mica(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 350,
                width: 300,
                decoration: BoxDecoration(
                  color: theme.resources.controlFillColorDefault,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: super.build(context),
              ),
            );
          },
        );
      },
    );
  }

  /// Closes the calendar date picker flyout.
  void close({bool force = false}) {
    _flyoutController.close<bool>(force);
  }

  @override
  void _onDayTapped(DateTime day, bool inScope) {
    super._onDayTapped(day, inScope);
    if (widget.closeOnSelection) {
      close();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    return FlyoutTarget(
      controller: _flyoutController,
      child: Button(
        onPressed: show,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            final resources = FluentTheme.of(context).resources;
            if (states.isDisabled) {
              return resources.textFillColorDisabled;
            } else {
              return resources.textFillColorSecondary;
            }
          }),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text(() {
              final locale = widget.locale ?? Localizations.localeOf(context);
              final selectedDate = _selectedStart;

              if (selectedDate != null) {
                final formatter =
                    widget.dateFormatter ?? DateFormat.yMd(locale.toString());

                return formatter.format(selectedDate);
              }

              final localizations = FluentLocalizations.of(context);

              return widget.placeholderText ?? localizations.pickADate;
            }()),
            const WindowsIcon(WindowsIcons.calendar),
          ],
        ),
      ),
    );
  }
}
