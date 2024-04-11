import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/form/pickers/pickers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

/// The duration of a complete year
const kYearDuration = Duration(days: 365);

/// Returns the amount of months in the desired year
Iterable<int> _monthsInYear(
  DateTime localDate,
  DateTime startDate,
  DateTime endDate,
) sync* {
  if (localDate.year == startDate.year) {
    for (var current = startDate.month; current <= 12; current++) {
      yield current;
    }
  } else if (localDate.year == endDate.year) {
    for (var current = endDate.month; current <= 12; current++) {
      yield current;
    }
  } else {
    yield* List.generate(DateTime.monthsPerYear, (index) => index + 1);
  }
}

/// The fields used on date picker.
enum DatePickerField {
  /// The month field
  month,

  /// The day field
  day,

  /// The year field
  year,
}

/// The date picker gives you a standardized way to let users pick a localized
/// date value using touch, mouse, or keyboard input.
///
/// ![DatePicker Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-datepicker-expand.gif)
///
/// See also:
///
///  * [TimePicker], which gives you a standardized way to let users pick a time
///    value
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/date-picker>
class DatePicker extends StatefulWidget {
  /// Creates a date picker.
  DatePicker({
    super.key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.header,
    this.headerStyle,
    this.showDay = true,
    this.showMonth = true,
    this.showYear = true,
    DateTime? startDate,
    DateTime? endDate,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPickerPopupHeight,
    this.focusNode,
    this.autofocus = false,
    this.locale,
    this.fieldOrder,
    this.fieldFlex,
  })  : startDate = startDate ?? DateTime.now().subtract(kYearDuration * 100),
        endDate = endDate ?? DateTime.now().add(kYearDuration * 25),
        assert(
          fieldFlex == null || fieldFlex.length == 3,
          'fieldFlex must be null or have a length of 3',
        );

  /// The current date selected date.
  ///
  /// If null, no date is going to be shown.
  final DateTime? selected;

  /// Whenever the current selected date is changed by the user.
  ///
  /// If null, the picker is considered disabled
  final ValueChanged<DateTime>? onChanged;

  /// Whenever the user cancels the date change.
  final VoidCallback? onCancel;

  /// The content of the header
  final String? header;

  /// The style of the [header]
  final TextStyle? headerStyle;

  /// Whenever to show the month field
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showYear], which configures whether to show the year field
  final bool showMonth;

  /// Whenever to show the day field
  ///
  /// See also:
  ///
  ///  * [showMonth], which configures whether to show the month field
  ///  * [showYear], which configures whether to show the year field
  final bool showDay;

  /// Whenever to show the year field
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showMonth], which configures whether to show the month field
  final bool showYear;

  /// The date displayed at the beggining
  ///
  /// Defaults to 100 to today
  final DateTime startDate;

  /// The date displayed at the end of the list
  ///
  /// Defaults to 25 years from today
  final DateTime endDate;

  /// The padding of the picker fields. Defaults to [kPickerContentPadding]
  final EdgeInsetsGeometry contentPadding;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The height of the popup.
  ///
  /// Defaults to [kPickerPopupHeight]
  final double popupHeight;

  /// The locale used to format the month name.
  ///
  /// If null, the system locale will be used.
  final Locale? locale;

  /// The order of the fields.
  ///
  /// If null, the order is based on the current locale.
  ///
  /// See also:
  ///
  ///  * [getDateOrderFromLocale], which returns the order of the fields based
  ///    on the current locale
  final List<DatePickerField>? fieldOrder;

  /// The flex of the fields.
  ///
  /// if null, the flex is base on the current locale.
  ///
  /// See also:
  ///
  /// * [getDateFlexFromLocale], which returns the flex of the fields based
  ///   on the current locale
  final List<int>? fieldFlex;

  @override
  State<DatePicker> createState() => _DatePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DateTime>('selected', selected, ifNull: 'now'))
      ..add(FlagProperty(
        'showMonth',
        value: showMonth,
        ifFalse: 'not displaying month',
      ))
      ..add(FlagProperty(
        'showDay',
        value: showDay,
        ifFalse: 'not displaying day',
      ))
      ..add(FlagProperty(
        'showYear',
        value: showYear,
        ifFalse: 'not displaying year',
      ))
      ..add(DiagnosticsProperty<DateTime>('startDate', startDate))
      ..add(DiagnosticsProperty<DateTime>('endDate', endDate))
      ..add(DiagnosticsProperty('contentPadding', contentPadding))
      ..add(ObjectFlagProperty.has('focusNode', focusNode))
      ..add(FlagProperty(
        'autofocus',
        value: autofocus,
        ifFalse: 'manual focus',
      ))
      ..add(DoubleProperty(
        'popupHeight',
        popupHeight,
        defaultValue: kPickerPopupHeight,
      ))
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(IterableProperty<DatePickerField>('fieldOrder', fieldOrder));
  }
}

class _DatePickerState extends State<DatePicker> {
  late DateTime date;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  int get startYear => widget.startDate.year;
  int get endYear => widget.endDate.year;

  int get currentYear {
    return List.generate(endYear - startYear + 1, (index) {
      return startYear + index;
    }).firstWhere((v) => v == date.year, orElse: () => 0);
  }

  @override
  void initState() {
    super.initState();
    date = widget.selected ?? DateTime.now();
    initControllers();
  }

  void initControllers() {
    if (widget.selected == null && mounted) {
      setState(() => date = DateTime.now());
    }
    _monthController = FixedExtentScrollController(
      initialItem: _monthsInYear(date, widget.startDate, widget.endDate)
          .toList()
          .indexOf(date.month),
    );
    _dayController = FixedExtentScrollController(
      initialItem: date.day - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: currentYear - startYear,
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != date) {
      date = widget.selected ?? DateTime.now();
      _monthController.jumpToItem(date.month - 1);
      _dayController.jumpToItem(date.day - 1);
      _yearController.jumpToItem(currentYear - startYear - 1);
    }
  }

  void handleDateChanged(DateTime newDate) {
    if (mounted) setState(() => date = newDate);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final fieldOrder = widget.fieldOrder ?? getDateOrderFromLocale(locale);
    final fieldFlex = widget.fieldFlex ?? getDateFlexFromLocale(locale);
    assert(fieldOrder.isNotEmpty);
    assert(
      fieldOrder.where((f) => f == DatePickerField.month).length <= 1,
      'There can be only one month field',
    );
    assert(
      fieldOrder.where((f) => f == DatePickerField.day).length <= 1,
      'There can be only one day field',
    );
    assert(
      fieldOrder.where((f) => f == DatePickerField.year).length <= 1,
      'There can be only one year field',
    );

    Widget picker = Picker(
      pickerContent: (context) {
        return _DatePickerContentPopUp(
          date: date,
          dayController: _dayController,
          monthController: _monthController,
          onCancel: () => widget.onCancel?.call(),
          onChanged: (date) => widget.onChanged?.call(date),
          showDay: widget.showDay,
          showMonth: widget.showMonth,
          showYear: widget.showYear,
          startDate: widget.startDate,
          endDate: widget.endDate,
          yearController: _yearController,
          locale: widget.locale,
          fieldOrder: fieldOrder,
          fieldFlex: fieldFlex,
        );
      },
      pickerHeight: widget.popupHeight,
      child: (context, open) => HoverButton(
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onPressed: () async {
          _monthController.dispose();
          // _monthController = null;
          _dayController.dispose();
          // _dayController = null;
          _yearController.dispose();
          // _yearController = null;
          initControllers();
          await open();
        },
        builder: (context, states) {
          if (states.isDisabled) states = <ButtonStates>{};
          const divider = Divider(
            direction: Axis.vertical,
            style: DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero,
            ),
          );

          final monthWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DatePickerField.month)],
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  widget.selected == null
                      ? localizations.month
                      : DateFormat(DateFormat.STANDALONE_MONTH, '$locale')
                          .format(widget.selected!)
                          .uppercaseFirst(),
                  locale: locale,
                ),
              ),
            )
          ];

          final dayWidget = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DatePickerField.day)],
              child: Text(
                widget.selected == null
                    ? localizations.day
                    : DateFormat.d('$locale').format(DateTime(
                        0,
                        0,
                        widget.selected!.day,
                      )),
                textAlign: TextAlign.center,
              ),
            ),
          ];

          final yearWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DatePickerField.year)],
              child: Text(
                widget.selected == null
                    ? localizations.year
                    : DateFormat.y('$locale').format(DateTime(
                        widget.selected!.year,
                      )),
                textAlign: TextAlign.center,
              ),
            ),
          ];

          final fields = <DatePickerField, List<Widget>>{
            if (widget.showYear) DatePickerField.year: yearWidgets,
            if (widget.showMonth) DatePickerField.month: monthWidgets,
            if (widget.showDay) DatePickerField.day: dayWidget,
          };

          final fieldMap = fieldOrder.map((e) => fields[e]);

          return FocusBorder(
            focused: states.isFocused,
            child: AnimatedContainer(
              duration: theme.fastAnimationDuration,
              curve: theme.animationCurve,
              height: kPickerHeight,
              decoration: kPickerDecorationBuilder(context, states),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: widget.selected == null
                      ? theme.resources.textFillColorSecondary
                      : null,
                ),
                maxLines: 1,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  ...fieldMap.elementAt(0) ?? [],
                  if (fieldMap.elementAt(1) != null) ...[
                    if (fieldMap.elementAt(0) != null) divider,
                    ...fieldMap.elementAt(1)!,
                  ],
                  if (fieldMap.elementAt(2) != null) ...[
                    divider,
                    ...fieldMap.elementAt(2)!,
                  ],
                ]),
              ),
            ),
          );
        },
      ),
    );
    if (widget.header != null) {
      return InfoLabel(
        label: widget.header!,
        labelStyle: widget.headerStyle,
        child: picker,
      );
    }
    return picker;
  }
}

class _DatePickerContentPopUp extends StatefulWidget {
  const _DatePickerContentPopUp({
    required this.showMonth,
    required this.showDay,
    required this.showYear,
    required this.date,
    required this.onChanged,
    required this.onCancel,
    required this.monthController,
    required this.dayController,
    required this.yearController,
    required this.startDate,
    required this.endDate,
    required this.locale,
    required this.fieldOrder,
    required this.fieldFlex,
  });

  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onCancel;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController dayController;
  final FixedExtentScrollController yearController;
  final DateTime startDate;
  final DateTime endDate;
  final Locale? locale;
  final List<DatePickerField> fieldOrder;
  final List<int> fieldFlex;

  @override
  State<_DatePickerContentPopUp> createState() =>
      __DatePickerContentPopUpState();
}

class __DatePickerContentPopUpState extends State<_DatePickerContentPopUp> {
  int _getDaysInMonth([int? month, int? year]) {
    year ??= DateTime.now().year;
    month ??= DateTime.now().month;
    return DateTimeRange(
      start: DateTime(year, month),
      end: DateTime(year, month + 1),
    ).duration.inDays;
  }

  late DateTime localDate = widget.date;

  Iterable<int> get monthsInCurrentYear {
    return _monthsInYear(localDate, widget.startDate, widget.endDate);
  }

  void handleDateChanged(DateTime time) {
    if (localDate == time || !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        localDate = time;
      });

      final monthIndex = monthsInCurrentYear.toList().indexOf(localDate.month);
      if (widget.showMonth &&
          widget.monthController.selectedItem != monthIndex) {
        widget.monthController.jumpToItem(monthIndex);
      }

      if (widget.showDay &&
          widget.dayController.selectedItem != localDate.day - 1) {
        widget.dayController.jumpToItem(localDate.day - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    const divider = Divider(
      direction: Axis.vertical,
      style: DividerThemeData(
        verticalMargin: EdgeInsets.zero,
        horizontalMargin: EdgeInsets.zero,
      ),
    );

    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final months = monthsInCurrentYear;
    final monthWidget = [
      Expanded(
        flex:
            widget.fieldFlex[widget.fieldOrder.indexOf(DatePickerField.month)],
        child: () {
          final formatter = DateFormat.MMMM(locale.toString());
          // MONTH
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.monthController.navigateSides(
                context,
                false,
                months.length,
              );
            },
            onForward: () {
              widget.monthController.navigateSides(
                context,
                true,
                months.length,
              );
            },
            child: ListWheelScrollView.useDelegate(
              controller: widget.monthController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(months.length, (index) {
                  final month = months.elementAt(index);
                  final text =
                      formatter.format(DateTime(1, month)).uppercaseFirst();
                  final selected = month == localDate.month;

                  return ListTile(
                    onPressed: selected
                        ? null
                        : () {
                            widget.monthController.animateToItem(
                              index,
                              duration: theme.mediumAnimationDuration,
                              curve: theme.animationCurve,
                            );
                          },
                    title: Text(
                      text,
                      style: kPickerPopupTextStyle(context, selected),
                      locale: locale,
                    ),
                  );
                }),
              ),
              onSelectedItemChanged: (index) {
                final month = months.elementAt(index);
                final daysInMonth = _getDaysInMonth(month, localDate.year);

                var day = localDate.day;
                if (day > daysInMonth) day = daysInMonth;

                handleDateChanged(DateTime(
                  localDate.year,
                  month,
                  day,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
            ),
          );
        }(),
      ),
    ];

    final dayWidget = [
      Expanded(
        flex: widget.fieldFlex[widget.fieldOrder.indexOf(DatePickerField.day)],
        child: () {
          // DAY
          final daysInMonth = _getDaysInMonth(localDate.month, localDate.year);
          final formatter = DateFormat.d(locale.toString());
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.dayController.navigateSides(
                context,
                false,
                daysInMonth,
              );
            },
            onForward: () {
              widget.dayController.navigateSides(
                context,
                true,
                daysInMonth,
              );
            },
            child: ListWheelScrollView.useDelegate(
              controller: widget.dayController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List<Widget>.generate(daysInMonth, (index) {
                  final day = index + 1;
                  final selected = day == localDate.day;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    key: ValueKey(day),
                    onPressed: selected
                        ? null
                        : () {
                            widget.dayController.animateToItem(
                              index,
                              duration: theme.mediumAnimationDuration,
                              curve: theme.animationCurve,
                            );
                          },
                    title: Center(
                      child: Text(
                        // '$day',
                        formatter.format(DateTime(
                          localDate.year,
                          localDate.month,
                          day,
                        )),
                        style: kPickerPopupTextStyle(context, selected),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }, growable: false),
              ),
              onSelectedItemChanged: (index) {
                handleDateChanged(DateTime(
                  localDate.year,
                  localDate.month,
                  index + 1,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
            ),
          );
        }(),
      ),
    ];

    final yearWidget = [
      Expanded(
        flex: widget.fieldFlex[widget.fieldOrder.indexOf(DatePickerField.year)],
        child: () {
          final years = widget.endDate.year - widget.startDate.year + 1;
          final formatter = DateFormat.y(locale.toString());
          // YEAR
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.yearController.navigateSides(
                context,
                false,
                years,
              );
            },
            onForward: () {
              widget.yearController.navigateSides(
                context,
                true,
                years,
              );
            },
            child: ListWheelScrollView(
              controller: widget.yearController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                var month = localDate.month;

                if (!monthsInCurrentYear.contains(month)) {
                  month = monthsInCurrentYear.first;
                }

                handleDateChanged(DateTime(
                  widget.startDate.year + index,
                  month,
                  localDate.day,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
              children: List.generate(years, (index) {
                final realYear = widget.startDate.year + index;
                final selected = realYear == localDate.year;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onPressed: selected
                      ? null
                      : () {
                          widget.yearController.animateToItem(
                            index,
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                          );
                        },
                  title: Text(
                    formatter.format(DateTime(realYear)),
                    style: kPickerPopupTextStyle(context, selected),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
          );
        }(),
      ),
    ];

    final fields = <DatePickerField, List<Widget>>{
      if (widget.showYear) DatePickerField.year: yearWidget,
      if (widget.showMonth) DatePickerField.month: monthWidget,
      if (widget.showDay) DatePickerField.day: dayWidget,
    };

    final fieldMap = widget.fieldOrder.map((e) => fields[e]);

    return Column(children: [
      Expanded(
        child: Stack(children: [
          PickerHighlightTile(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            ...fieldMap.elementAt(0) ?? [],
            if (fieldMap.elementAt(1) != null) ...[
              divider,
              ...fieldMap.elementAt(1)!,
            ],
            if (fieldMap.elementAt(2) != null) ...[
              divider,
              ...fieldMap.elementAt(2)!,
            ],
          ]),
        ]),
      ),
      const Divider(
        style: DividerThemeData(
          verticalMargin: EdgeInsets.zero,
          horizontalMargin: EdgeInsets.zero,
        ),
      ),
      YesNoPickerControl(
        onChanged: () {
          widget.onChanged(localDate);
          Navigator.pop(context);
        },
        onCancel: () {
          widget.onCancel();
          Navigator.pop(context);
        },
      ),
    ]);
  }
}

/// Get the date order based on the current locale.
///
///
/// ![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Date_format_by_country_NEW.svg/700px-Date_format_by_country_NEW.svg.png)
///
/// DMY is mostly used around the globe, so that's the returned
///
/// See also:
///
///  * <https://en.wikipedia.org/wiki/Date_format_by_country>
List<DatePickerField> getDateOrderFromLocale(Locale? locale) {
  final dmy = [
    DatePickerField.day,
    DatePickerField.month,
    DatePickerField.year,
  ];
  final ymd = [
    DatePickerField.year,
    DatePickerField.month,
    DatePickerField.day,
  ];
  final mdy = [
    DatePickerField.month,
    DatePickerField.day,
    DatePickerField.year,
  ];

  if (locale?.countryCode?.toLowerCase() == 'us') return mdy;

  final lang = locale?.languageCode;

  if (['zh', 'ko', 'jp'].contains(lang)) return ymd;

  return dmy;
}

/// Get the date flex based on the current locale.
/// The flex is used to determine the width of the fields.
List<int> getDateFlexFromLocale(Locale? locale) {
  final lang = locale?.languageCode;
  if (locale?.countryCode?.toLowerCase() == 'us') return const [2, 1, 1];

  if (['zh', 'ko'].contains(lang)) return const [1, 1, 1];

  return [1, 2, 1];
}
