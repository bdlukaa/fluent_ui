import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import 'package:fluent_ui/src/utils/popup.dart';

import 'pickers.dart';

/// The time picker gives you a standardized way to let users pick a time
/// value using touch, mouse, or keyboard input. Use a time picker to let
/// a user pick a single time value.
///
/// ![TimePicker Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_timepicker_expand.png)7
///
/// See also:
///
/// - [TimePicker Documentation](https://pub.dev/packages/fluent_ui#time-picker)
/// - [DatePicker](https://pub.dev/packages/fluent_ui#date-picker)
class TimePicker extends StatefulWidget {
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
    this.hourPlaceholder = 'hour',
    this.minutePlaceholder = 'minute',
    this.amText = 'AM',
    this.pmText = 'PM',
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

  final String hourPlaceholder;
  final String minutePlaceholder;
  final String amText;
  final String pmText;

  final double popupHeight;
  final double minuteIncrement;

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
    properties.add(StringProperty('hourPlaceholder', hourPlaceholder));
    properties.add(StringProperty('minutePlaceholder', minutePlaceholder));
    properties.add(StringProperty('amText', amText));
    properties.add(StringProperty('pmText', pmText));
    properties.add(DoubleProperty('popupHeight', popupHeight));
  }
}

class _TimePickerState extends State<TimePicker> {
  late DateTime time;

  final popupKey = GlobalKey<PopUpState>();

  FixedExtentScrollController? _hourController;
  FixedExtentScrollController? _minuteController;
  FixedExtentScrollController? _amPmController;

  bool am = true;

  @override
  void initState() {
    super.initState();
    time = widget.selected ?? DateTime.now();
    initControllers();
  }

  @override
  void dispose() {
    _hourController?.dispose();
    _minuteController?.dispose();
    _amPmController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != time) {
      time = widget.selected ?? DateTime.now();
      _hourController?.jumpToItem(() {
        int hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }());
      _minuteController?.jumpToItem(time.minute);
      _amPmController?.jumpToItem(_isPm ? 1 : 0);
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

  bool get _isPm => time.hour > 12;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Widget picker = HoverButton(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onPressed: () async {
        await popupKey.currentState?.openPopup();
        _hourController?.dispose();
        _hourController = null;
        _minuteController?.dispose();
        _minuteController = null;
        _amPmController?.dispose();
        _amPmController = null;
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
          child: Row(children: [
            Expanded(
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  () {
                    int hour = time.hour;
                    if (!widget.use24Format && hour > 12) return '${hour - 12}';
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
                child: Text('${time.minute}', textAlign: TextAlign.center),
              ),
            ),
            divider,
            if (!widget.use24Format)
              Expanded(
                child: Padding(
                  padding: widget.contentPadding,
                  child: Text(
                    () {
                      if (_isPm) return widget.pmText;
                      return widget.amText;
                    }(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ]),
        );
      },
    );
    picker = PopUp(
      key: popupKey,
      child: picker,
      content: (context) => _TimePickerContentPopup(
        height: widget.popupHeight,
        onCancel: widget.onCancel ?? () {},
        onChanged: () => widget.onChanged?.call(time),
        amText: widget.amText,
        pmText: widget.pmText,
        handleDateChanged: handleDateChanged,
        date: widget.selected ?? DateTime.now(),
        amPmController: _amPmController!,
        hourController: _hourController!,
        minuteController: _minuteController!,
        use24Format: widget.use24Format,
        minuteIncrement: widget.minuteIncrement,
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
    required this.amText,
    required this.pmText,
    required this.handleDateChanged,
    required this.hourController,
    required this.minuteController,
    required this.amPmController,
    required this.use24Format,
    required this.height,
    required this.minuteIncrement,
  }) : super(key: key);

  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController amPmController;

  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final DateTime date;
  final String amText;
  final String pmText;
  final ValueChanged<DateTime> handleDateChanged;

  final bool use24Format;
  final double height;
  final double minuteIncrement;

  @override
  __TimePickerContentPopupState createState() =>
      __TimePickerContentPopupState();
}

class __TimePickerContentPopupState extends State<_TimePickerContentPopup> {
  bool get isAm => widget.amPmController.selectedItem == 0;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
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
    return SizedBox(
      height: widget.height,
      child: Acrylic(
        tint: kPickerBackgroundColor(context),
        shape: kPickerShape(context),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              kHighlightTile(),
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
                          (index) => ListTile(
                            title: Center(
                              child: Text(
                                '${index + 1}',
                                style: kPickerPopupTextStyle(context),
                              ),
                            ),
                          ),
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
                        widget.handleDateChanged(DateTime(
                          widget.date.year,
                          widget.date.month,
                          widget.date.day,
                          hour,
                          widget.date.minute,
                          widget.date.second,
                          widget.date.millisecond,
                          widget.date.microsecond,
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
                        children: List.generate(60 ~/ widget.minuteIncrement,
                            (index) {
                          return ListTile(
                            title: Center(
                              child: Text(
                                '${(index * widget.minuteIncrement).toInt()}',
                                style: kPickerPopupTextStyle(context),
                              ),
                            ),
                          );
                        }),
                      ),
                      itemExtent: kOneLineTileHeight,
                      diameterRatio: kPickerDiameterRatio,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        widget.handleDateChanged(DateTime(
                          widget.date.year,
                          widget.date.month,
                          widget.date.day,
                          widget.date.hour,
                          index,
                          widget.date.second,
                          widget.date.millisecond,
                          widget.date.microsecond,
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
                                widget.amText,
                                style: kPickerPopupTextStyle(context),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                widget.pmText,
                                style: kPickerPopupTextStyle(context),
                              ),
                            ),
                          ),
                        ],
                        onSelectedItemChanged: (index) {
                          setState(() {});
                          int hour = widget.date.hour;
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
                          widget.handleDateChanged(DateTime(
                            widget.date.year,
                            widget.date.month,
                            widget.date.day,
                            hour,
                            widget.date.minute,
                            widget.date.second,
                            widget.date.millisecond,
                            widget.date.microsecond,
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
              widget.onChanged();
            },
            onCancel: () {
              Navigator.pop(context);
              widget.onCancel();
            },
          ),
        ]),
      ),
    );
  }
}
