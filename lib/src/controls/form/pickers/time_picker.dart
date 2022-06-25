import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import 'pickers.dart';

/// The time picker gives you a standardized way to let users pick a time value
/// using touch, mouse, or keyboard input.
///
/// ![TimePicker Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-timepicker-expand.gif)
///
/// See also:
///
///  * [DatePicker], which gives you a standardized way to let users pick a
///    localized date value
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/time-picker>
class TimePicker extends StatefulWidget {
  /// Creates a time picker.
  const TimePicker({
    Key? key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.header,
    this.headerStyle,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPopupHeight,
    this.focusNode,
    this.autofocus = false,
    this.hourFormat = HourFormat.h,
    this.minuteIncrement = 1,
  }) : super(key: key);

  final DateTime? selected;
  final ValueChanged<DateTime>? onChanged;
  final VoidCallback? onCancel;
  final HourFormat hourFormat;

  final String? header;
  final TextStyle? headerStyle;

  final EdgeInsetsGeometry contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;

  final double popupHeight;
  final int minuteIncrement;

  bool get use24Format => [HourFormat.HH, HourFormat.H].contains(hourFormat);

  @override
  _TimePickerState createState() => _TimePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('selected', selected));
    properties.add(EnumProperty<HourFormat>('hourFormat', hourFormat));
    properties.add(DiagnosticsProperty('contentPadding', contentPadding));
    properties.add(ObjectFlagProperty.has('focusNode', focusNode));
    properties.add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'));
    properties.add(DoubleProperty('popupHeight', popupHeight));
  }
}

class _TimePickerState extends State<TimePicker> {
  late DateTime time;

  final GlobalKey _buttonKey = GlobalKey();

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  bool am = true;

  @override
  void initState() {
    super.initState();
    time = widget.selected ?? DateTime.now();
    initControllers();
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
    if (widget.selected != time) {
      time = widget.selected ?? DateTime.now();
      _hourController.jumpToItem(() {
        int hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }());
      _minuteController.jumpToItem(time.minute);
      _amPmController.jumpToItem(_isPm ? 1 : 0);
    }
  }

  void handleDateChanged(DateTime date) {
    setState(() => time = date);
  }

  void initControllers() {
    _hourController = FixedExtentScrollController(
      initialItem: () {
        int hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }(),
    );
    _minuteController = FixedExtentScrollController(initialItem: time.minute);

    _amPmController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  bool get _isPm => time.hour >= 12;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final localizations = FluentLocalizations.of(context);

    Widget picker = Picker(
      pickerHeight: widget.popupHeight,
      pickerContent: (context) {
        return _TimePickerContentPopup(
          onCancel: widget.onCancel ?? () {},
          onChanged: (time) => widget.onChanged?.call(time),
          date: widget.selected ?? DateTime.now(),
          amPmController: _amPmController,
          hourController: _hourController,
          minuteController: _minuteController,
          use24Format: widget.use24Format,
          minuteIncrement: widget.minuteIncrement,
        );
      },
      child: (context, open) => HoverButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: () async {
          await open();
          _hourController.dispose();
          _minuteController.dispose();
          _amPmController.dispose();
          initControllers();
        },
        builder: (context, state) {
          const divider = Divider(
            direction: Axis.vertical,
            style: DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero,
              thickness: 0.6,
            ),
          );
          return AnimatedContainer(
            duration: FluentTheme.of(context).fastAnimationDuration,
            curve: FluentTheme.of(context).animationCurve,
            height: kPickerHeight,
            decoration: kPickerDecorationBuilder(context, state),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.selected == null
                    ? FluentTheme.of(context).resources.textFillColorSecondary
                    : null,
              ),
              child: Row(key: _buttonKey, children: [
                Expanded(
                  child: Padding(
                    padding: widget.contentPadding,
                    child: Text(
                      () {
                        if (widget.selected == null) return localizations.hour;
                        int hour = time.hour;
                        if (!widget.use24Format && hour > 12) {
                          return '${hour - 12}';
                        }
                        return '$hour';
                      }(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                divider,
                Expanded(
                  child: Padding(
                    padding: widget.contentPadding,
                    child: Text(
                      widget.selected == null
                          ? localizations.minute
                          : '${time.minute}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                divider,
                if (!widget.use24Format)
                  Expanded(
                    child: Padding(
                      padding: widget.contentPadding,
                      child: Text(
                        () {
                          if (_isPm) return localizations.pm;
                          return localizations.am;
                        }(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ]),
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

class _TimePickerContentPopup extends StatefulWidget {
  const _TimePickerContentPopup({
    Key? key,
    required this.date,
    required this.onChanged,
    required this.onCancel,
    required this.hourController,
    required this.minuteController,
    required this.amPmController,
    required this.use24Format,
    required this.minuteIncrement,
  }) : super(key: key);

  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController amPmController;

  final ValueChanged<DateTime> onChanged;
  final VoidCallback onCancel;
  final DateTime date;

  final bool use24Format;
  final int minuteIncrement;

  @override
  __TimePickerContentPopupState createState() =>
      __TimePickerContentPopupState();
}

class __TimePickerContentPopupState extends State<_TimePickerContentPopup> {
  bool get isAm => widget.amPmController.selectedItem == 0;

  late DateTime localDate = widget.date;

  void handleDateChanged(DateTime time) {
    setState(() => localDate = time);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final localizations = FluentLocalizations.of(context);

    const divider = Divider(
      direction: Axis.vertical,
      style: DividerThemeData(
        verticalMargin: EdgeInsets.zero,
        horizontalMargin: EdgeInsets.zero,
      ),
    );
    final duration = FluentTheme.of(context).fasterAnimationDuration;
    final curve = FluentTheme.of(context).animationCurve;
    final hoursAmount = widget.use24Format ? 24 : 12;
    return Column(children: [
      Expanded(
        child: Stack(children: [
          PickerHighlightTile(),
          Row(children: [
            Expanded(
              child: PickerNavigatorIndicator(
                onBackward: () {
                  navigateSides(
                    context,
                    widget.hourController,
                    false,
                    hoursAmount,
                  );
                },
                onForward: () {
                  navigateSides(
                    context,
                    widget.hourController,
                    true,
                    hoursAmount,
                  );
                },
                child: ListWheelScrollView.useDelegate(
                  controller: widget.hourController,
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(
                      hoursAmount,
                      (index) {
                        final hour = index + 1;
                        final realHour = () {
                          if (!widget.use24Format && localDate.hour > 12) {
                            return hour + 12;
                          }
                          return hour;
                        }();
                        return ListTile(
                          title: Center(
                            child: Text(
                              '$hour',
                              style: kPickerPopupTextStyle(
                                context,
                                localDate.hour == realHour,
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
                    int hour = index + 1;
                    if (!widget.use24Format && !isAm) {
                      hour += 12;
                    }
                    handleDateChanged(DateTime(
                      localDate.year,
                      localDate.month,
                      localDate.day,
                      hour,
                      localDate.minute,
                      localDate.second,
                      localDate.millisecond,
                      localDate.microsecond,
                    ));
                  },
                ),
              ),
            ),
            divider,
            Expanded(
              child: PickerNavigatorIndicator(
                onBackward: () {
                  navigateSides(
                    context,
                    widget.minuteController,
                    false,
                    60,
                  );
                },
                onForward: () {
                  navigateSides(
                    context,
                    widget.minuteController,
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
                        final int minute = index * widget.minuteIncrement;
                        return ListTile(
                          title: Center(
                            child: Text(
                              '$minute',
                              style: kPickerPopupTextStyle(
                                context,
                                minute == localDate.minute,
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
                    final int minute = index * widget.minuteIncrement;
                    handleDateChanged(DateTime(
                      localDate.year,
                      localDate.month,
                      localDate.day,
                      localDate.hour,
                      minute,
                      localDate.second,
                      localDate.millisecond,
                      localDate.microsecond,
                    ));
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
                      ListTile(
                        title: Center(
                          child: Text(
                            localizations.am,
                            style: kPickerPopupTextStyle(
                              context,
                              localDate.hour < 12,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Center(
                          child: Text(
                            localizations.pm,
                            style: kPickerPopupTextStyle(
                              context,
                              localDate.hour >= 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onSelectedItemChanged: (index) {
                      setState(() {});
                      int hour = localDate.hour;
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
                      handleDateChanged(DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                        hour,
                        localDate.minute,
                        localDate.second,
                        localDate.millisecond,
                        localDate.microsecond,
                      ));
                    },
                  ),
                ),
              ),
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
          Navigator.pop(context);
          widget.onChanged(localDate);
        },
        onCancel: () {
          Navigator.pop(context);
          widget.onCancel();
        },
      ),
    ]);
  }
}
