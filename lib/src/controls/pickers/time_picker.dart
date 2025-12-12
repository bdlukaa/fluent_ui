import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:fluent_ui/src/intl_script_locale_apply_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

String _formatHour(int hour, String locale) {
  return DateFormat.H(locale).format(
    DateTime(
      0, // year
      0, // month
      0, // day
      hour,
    ),
  );
}

String _formatMinute(int minute, String locale) {
  return DateFormat.m(locale).format(
    DateTime(
      0, // year
      0, // month
      0, // day
      0, // hour,
      minute,
    ),
  );
}

/// A picker control that lets users select a time.
///
/// The time picker provides a standardized way for users to pick a time value
/// using touch, mouse, or keyboard input. It displays separate fields for
/// hour, minute, and optionally AM/PM that expand into scrollable lists.
///
/// ![TimePicker Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/controls-timepicker-expand.gif)
///
/// {@tool snippet}
/// This example shows a basic time picker:
///
/// ```dart
/// TimePicker(
///   selected: selectedTime,
///   onChanged: (time) => setState(() => selectedTime = time),
///   header: 'Select a time',
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a 24-hour format time picker with 15-minute increments:
///
/// ```dart
/// TimePicker(
///   selected: selectedTime,
///   onChanged: (time) => setState(() => selectedTime = time),
///   hourFormat: HourFormat.HH,
///   minuteIncrement: 15,
/// )
/// ```
/// {@end-tool}
///
/// ## Hour formats
///
/// Use [hourFormat] to specify the clock system:
///
/// * [HourFormat.h] - 12-hour format with AM/PM
/// * [HourFormat.HH] - 24-hour format
///
/// See also:
///
///  * [DatePicker], for selecting date values
///  * [CalendarView], for selecting dates from a calendar
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/time-picker>
class TimePicker extends StatefulWidget {
  /// Creates a time picker.
  const TimePicker({
    required this.selected,
    super.key,
    this.onChanged,
    this.onCancel,
    this.hourFormat = HourFormat.h,
    this.header,
    this.headerStyle,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPickerPopupHeight,
    this.focusNode,
    this.autofocus = false,
    this.minuteIncrement = 1,
    this.locale,
  });

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

  /// The clock system to use
  final HourFormat hourFormat;

  /// The content of the header
  final String? header;

  /// The style of the [header]
  final TextStyle? headerStyle;

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

  /// The value that indicates the time increments shown in the minute picker.
  /// For example, 15 specifies that the TimePicker minute control displays
  /// only the choices 00, 15, 30, 45.
  ///
  /// ![15 minute increment preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/date-time/time-picker-minute-increment.png)
  ///
  /// Defaults to 1
  final int minuteIncrement;

  /// The locale used to format the month name.
  ///
  /// If null, the system locale will be used.
  final Locale? locale;

  /// Whether the time picker is using the 24-hour format.
  bool get use24Format => [HourFormat.HH, HourFormat.H].contains(hourFormat);

  @override
  State<TimePicker> createState() => TimePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DateTime>('selected', selected, ifNull: 'now'))
      ..add(
        EnumProperty<HourFormat>(
          'hourFormat',
          hourFormat,
          defaultValue: HourFormat.h,
        ),
      )
      ..add(
        DiagnosticsProperty(
          'contentPadding',
          contentPadding,
          defaultValue: kPickerContentPadding,
        ),
      )
      ..add(ObjectFlagProperty.has('focusNode', focusNode))
      ..add(
        FlagProperty(
          'autofocus',
          value: autofocus,
          ifFalse: 'manual focus',
          defaultValue: false,
        ),
      )
      ..add(
        DoubleProperty(
          'popupHeight',
          popupHeight,
          defaultValue: kPickerPopupHeight,
        ),
      )
      ..add(IntProperty('minuteIncrement', minuteIncrement, defaultValue: 1));
  }
}

class TimePickerState extends State<TimePicker>
    with IntlScriptLocaleApplyMixin {
  late DateTime _time;

  final GlobalKey _buttonKey = GlobalKey(debugLabel: 'Time Picker button key');

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  final _pickerKey = GlobalKey<PickerState>();

  @override
  void initState() {
    super.initState();
    _time = widget.selected ?? DateTime.now();
    _initControllers();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != _time) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _time = widget.selected ?? DateTime.now();
        _hourController.jumpToItem(() {
          var hour = _time.hour;
          if (!widget.use24Format) {
            hour -= 12;
          }
          return hour;
        }());
        _minuteController.jumpToItem(_time.minute);
        _amPmController.jumpToItem(isPm ? 1 : 0);
      });
    }
  }

  /// Update the current time with a new time.
  void handleDateChanged(DateTime date) {
    setState(() => _time = date);
  }

  void _initControllers() {
    if (widget.selected == null && mounted) {
      setState(() => _time = DateTime.now());
    }
    _hourController = FixedExtentScrollController(
      initialItem: () {
        var hour = _time.hour;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }(),
    );
    _minuteController = FixedExtentScrollController(initialItem: _time.minute);

    _amPmController = FixedExtentScrollController(initialItem: isPm ? 1 : 0);
  }

  /// Whether the current time is in the PM period.
  bool get isPm => _time.hour >= 12;

  /// Open the time picker popup.
  void open() {
    _pickerKey.currentState?.open();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final Widget picker = Picker(
      key: _pickerKey,
      pickerHeight: widget.popupHeight,
      pickerContent: (context) {
        return _TimePickerContentPopup(
          onCancel: widget.onCancel ?? () {},
          onChanged: (time) {
            handleDateChanged(time);
            widget.onChanged?.call(time);
          },
          date: widget.selected ?? DateTime.now(),
          amPmController: _amPmController,
          hourController: _hourController,
          minuteController: _minuteController,
          use24Format: widget.use24Format,
          minuteIncrement: widget.minuteIncrement,
          locale: locale,
        );
      },
      child: (context, open) => HoverButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: widget.onChanged == null
            ? null
            : () async {
                _hourController.dispose();
                _minuteController.dispose();
                _amPmController.dispose();
                _initControllers();
                await open();
              },
        builder: (context, states) {
          const divider = Divider(
            direction: Axis.vertical,
            style: DividerThemeData(
              verticalMargin: EdgeInsetsDirectional.zero,
              horizontalMargin: EdgeInsetsDirectional.zero,
            ),
          );
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
                child: Row(
                  key: _buttonKey,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: widget.contentPadding,
                        child: Text(() {
                          if (widget.selected == null) {
                            return localizations.hour;
                          }
                          late int finalHour;
                          final hour = _time.hour;
                          if (!widget.use24Format && hour > 12) {
                            finalHour = hour - 12;
                          } else {
                            finalHour = hour;
                          }

                          return _formatHour(finalHour, locale!.toString());
                        }(), textAlign: TextAlign.center),
                      ),
                    ),
                    divider,
                    Expanded(
                      child: Padding(
                        padding: widget.contentPadding,
                        child: Text(
                          widget.selected == null
                              ? localizations.minute
                              : _formatMinute(_time.minute, '$locale'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    divider,
                    if (!widget.use24Format)
                      Expanded(
                        child: Padding(
                          padding: widget.contentPadding,
                          child: Text(() {
                            if (isPm) return localizations.pm;
                            return localizations.am;
                          }(), textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
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

// Since hours goes from 0 to 23, it is not needed to add 1 to the index since
// it already starts from 0.
class _TimePickerContentPopup extends StatefulWidget {
  const _TimePickerContentPopup({
    required this.date,
    required this.onChanged,
    required this.onCancel,
    required this.hourController,
    required this.minuteController,
    required this.amPmController,
    required this.use24Format,
    required this.minuteIncrement,
    required this.locale,
  });

  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController amPmController;

  final ValueChanged<DateTime> onChanged;
  final VoidCallback onCancel;
  final DateTime date;
  final Locale? locale;

  final bool use24Format;
  final int minuteIncrement;

  @override
  State<_TimePickerContentPopup> createState() =>
      __TimePickerContentPopupState();
}

class __TimePickerContentPopupState extends State<_TimePickerContentPopup> {
  bool get isAm => widget.amPmController.selectedItem == 0;

  late DateTime localDate;

  @override
  void initState() {
    super.initState();
    localDate = widget.date;
    final possibleMinutes = List.generate(
      60 ~/ widget.minuteIncrement,
      (index) => index * widget.minuteIncrement,
    );
    if (!possibleMinutes.contains(localDate.minute)) {
      localDate = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
        localDate.hour,
        getClosestMinute(possibleMinutes, localDate.minute),
        localDate.second,
        localDate.millisecond,
        localDate.microsecond,
      );
    }
  }

  void handleDateChanged(DateTime time) {
    localDate = time;
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  int getClosestMinute(List<int> possibleMinutes, int goal) {
    return possibleMinutes
        .reduce(
          (prev, curr) =>
              (curr - goal).abs() < (prev - goal).abs() ? curr : prev,
        )
        .clamp(0, 59);
  }

  void onSelect() {
    Navigator.pop(context);
    widget.onChanged(localDate);
  }

  void onDismiss() {
    Navigator.pop(context);
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    const divider = Divider(
      direction: Axis.vertical,
      style: DividerThemeData(
        verticalMargin: EdgeInsetsDirectional.zero,
        horizontalMargin: EdgeInsetsDirectional.zero,
      ),
    );
    final duration = theme.fasterAnimationDuration;
    final curve = theme.animationCurve;
    final hoursAmount = widget.use24Format ? 24 : 12;

    return PickerDialog(
      onSelect: onSelect,
      onDismiss: onDismiss,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const PickerHighlightTile(),
                Row(
                  children: [
                    Expanded(
                      child: PickerNavigatorIndicator(
                        onBackward: () {
                          widget.hourController.navigateSides(
                            context,
                            false,
                            hoursAmount,
                          );
                        },
                        onForward: () {
                          widget.hourController.navigateSides(
                            context,
                            true,
                            hoursAmount,
                          );
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: widget.hourController,
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(hoursAmount, (hour) {
                              final realHour = () {
                                if (!widget.use24Format &&
                                    localDate.hour > 12) {
                                  return hour + 12;
                                }
                                return hour;
                              }();
                              final selected = localDate.hour == realHour;

                              return ListTile(
                                onPressed: selected
                                    ? null
                                    : () {
                                        widget.hourController.animateToItem(
                                          hour,
                                          duration:
                                              theme.mediumAnimationDuration,
                                          curve: theme.animationCurve,
                                        );
                                      },
                                title: Center(
                                  child: Text(
                                    _formatHour(
                                      hour,
                                      widget.locale!.toString(),
                                    ),
                                    style: kPickerPopupTextStyle(
                                      context,
                                      selected,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          itemExtent: kOneLineTileHeight,
                          diameterRatio: kPickerDiameterRatio,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (hour) {
                            if (!widget.use24Format && !isAm) {
                              hour += 12;
                            }
                            handleDateChanged(
                              DateTime(
                                localDate.year,
                                localDate.month,
                                localDate.day,
                                hour,
                                localDate.minute,
                                localDate.second,
                                localDate.millisecond,
                                localDate.microsecond,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    divider,
                    Expanded(
                      child: PickerNavigatorIndicator(
                        onBackward: () {
                          widget.minuteController.navigateSides(
                            context,
                            false,
                            60,
                          );
                        },
                        onForward: () {
                          widget.minuteController.navigateSides(
                            context,
                            true,
                            60,
                          );
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: widget.minuteController,
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(
                              60 ~/ widget.minuteIncrement,
                              (index) {
                                final minute = index * widget.minuteIncrement;
                                final selected = minute == localDate.minute;
                                return ListTile(
                                  onPressed: selected
                                      ? null
                                      : () {
                                          widget.minuteController.animateToItem(
                                            index,
                                            duration:
                                                theme.mediumAnimationDuration,
                                            curve: theme.animationCurve,
                                          );
                                        },
                                  title: Center(
                                    child: Text(
                                      _formatMinute(minute, '${widget.locale}'),
                                      style: kPickerPopupTextStyle(
                                        context,
                                        selected,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          itemExtent: kOneLineTileHeight,
                          diameterRatio: kPickerDiameterRatio,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            final minute = index * widget.minuteIncrement;
                            handleDateChanged(
                              DateTime(
                                localDate.year,
                                localDate.month,
                                localDate.day,
                                localDate.hour,
                                minute,
                                localDate.second,
                                localDate.millisecond,
                                localDate.microsecond,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (!widget.use24Format) ...[
                      divider,
                      Expanded(
                        child: PickerNavigatorIndicator(
                          onBackward: () {
                            widget.amPmController.animateToItem(
                              0,
                              duration: duration,
                              curve: curve,
                            );
                          },
                          onForward: () {
                            widget.amPmController.animateToItem(
                              1,
                              duration: duration,
                              curve: curve,
                            );
                          },
                          child: ListWheelScrollView(
                            controller: widget.amPmController,
                            itemExtent: kOneLineTileHeight,
                            physics: const FixedExtentScrollPhysics(),
                            children: [
                              () {
                                final selected = localDate.hour < 12;
                                return ListTile(
                                  onPressed: selected
                                      ? null
                                      : () {
                                          widget.amPmController.animateToItem(
                                            0,
                                            duration:
                                                theme.mediumAnimationDuration,
                                            curve: theme.animationCurve,
                                          );
                                        },
                                  title: Center(
                                    child: Text(
                                      localizations.am,
                                      style: kPickerPopupTextStyle(
                                        context,
                                        selected,
                                      ),
                                    ),
                                  ),
                                );
                              }(),
                              () {
                                final selected = localDate.hour >= 12;
                                return ListTile(
                                  onPressed: selected
                                      ? null
                                      : () {
                                          widget.amPmController.animateToItem(
                                            1,
                                            duration:
                                                theme.mediumAnimationDuration,
                                            curve: theme.animationCurve,
                                          );
                                        },
                                  title: Center(
                                    child: Text(
                                      localizations.pm,
                                      style: kPickerPopupTextStyle(
                                        context,
                                        selected,
                                      ),
                                    ),
                                  ),
                                );
                              }(),
                            ],
                            onSelectedItemChanged: (index) {
                              // setState(() {});
                              var hour = localDate.hour;
                              final isAm = index == 0;
                              if (!widget.use24Format) {
                                // If it was previously am and now it's pm
                                if (!isAm) {
                                  hour += 12;
                                  // If it was previously pm and now it's am
                                } else if (isAm) {
                                  hour -= 12;
                                }
                              }
                              handleDateChanged(
                                DateTime(
                                  localDate.year,
                                  localDate.month,
                                  localDate.day,
                                  hour,
                                  localDate.minute,
                                  localDate.second,
                                  localDate.millisecond,
                                  localDate.microsecond,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            style: DividerThemeData(
              verticalMargin: EdgeInsetsDirectional.zero,
              horizontalMargin: EdgeInsetsDirectional.zero,
            ),
          ),
          YesNoPickerControl(onChanged: onSelect, onCancel: onDismiss),
        ],
      ),
    );
  }
}
