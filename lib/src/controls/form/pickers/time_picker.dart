import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import 'package:fluent_ui/src/utils/popup.dart';

import 'pickers.dart';

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
    this.cursor = SystemMouseCursors.click,
    this.focusNode,
    this.autofocus = false,
    this.hourFormat = HourFormat.h,
    this.hourPlaceholder = 'hour',
    this.minutePlaceholder = 'minute',
    this.amText = 'AM',
    this.pmText = 'PM',
  }) : super(key: key);

  final DateTime? selected;
  final ValueChanged<DateTime>? onChanged;
  final VoidCallback? onCancel;
  final HourFormat hourFormat;

  final String? header;
  final TextStyle? headerStyle;

  final EdgeInsetsGeometry contentPadding;
  final MouseCursor cursor;
  final FocusNode? focusNode;
  final bool autofocus;

  final String hourPlaceholder;
  final String minutePlaceholder;
  final String amText;
  final String pmText;

  final double popupHeight;

  bool get use24Format => [HourFormat.HH, HourFormat.H].contains(hourFormat);

  @override
  _TimePickerState createState() => _TimePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('selected', selected));
    properties.add(EnumProperty<HourFormat>('hourFormat', hourFormat));
    properties.add(DiagnosticsProperty('contentPadding', contentPadding));
    properties.add(DiagnosticsProperty('cursor', cursor));
    properties.add(ObjectFlagProperty.has('focusNode', focusNode));
    properties.add(FlagProperty('autofocus', value: autofocus));
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
      _minuteController?.jumpToItem(time.minute - 1);
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
    _minuteController = FixedExtentScrollController(
      initialItem: time.minute - 1,
    );

    _amPmController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  bool get _isPm => time.hour > 12;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    Widget picker = HoverButton(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      cursor: (_) => widget.cursor,
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
        final divider = Divider(
          direction: Axis.vertical,
          style: DividerStyle(
            margin: (_) => EdgeInsets.zero,
            thickness: 0.6,
          ),
        );
        return AnimatedContainer(
          duration: context.theme.fastAnimationDuration ?? Duration.zero,
          curve: context.theme.animationCurve ?? Curves.linear,
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
      backgroundColor: context.theme.navigationPanelBackgroundColor,
      contentHeight: widget.popupHeight,
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
      ),
    );
    if (widget.header != null) {
      return InfoHeader(
        header: widget.header!,
        headerStyle: widget.headerStyle,
        child: picker,
      );
    }
    return picker;
  }
}

class _TimePickerContentPopup extends StatefulWidget {
  _TimePickerContentPopup({
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

  @override
  __TimePickerContentPopupState createState() =>
      __TimePickerContentPopupState();
}

class __TimePickerContentPopupState extends State<_TimePickerContentPopup> {
  bool get isAm => widget.amPmController.selectedItem == 0;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final divider = Divider(
      direction: Axis.vertical,
      style: DividerStyle(margin: (_) => EdgeInsets.zero),
    );
    final duration = context.theme.fasterAnimationDuration ?? Duration.zero;
    final curve = context.theme.animationCurve ?? Curves.linear;
    final hoursAmount = widget.use24Format ? 24 : 12;
    return Acrylic(
      height: widget.height,
      decoration: kPickerBackgroundDecoration(context),
      child: Column(children: [
        Expanded(
          child: Stack(children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                height: kOneLineTileHeight,
                child: ListTile(
                  tileColor: context.theme.accentColor?.withOpacity(0.4),
                ),
              ),
            ),
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
                      int _hour = index + 1;
                      if (!widget.use24Format && !isAm) {
                        _hour += 12;
                      }
                      widget.handleDateChanged(DateTime(
                        widget.date.year,
                        widget.date.month,
                        widget.date.day,
                        _hour,
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
                      children: List.generate(60, (index) {
                        return ListTile(
                          title: Center(
                            child: Text(
                              '${index + 1}',
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
                        index + 1,
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
                        int _hour = widget.date.hour;
                        final isAm = index == 0;
                        if (!widget.use24Format) {
                          // If it was previously am and now it's pm
                          if (!isAm) {
                            _hour += 12;
                            // If it was previously pm and now it's am
                          } else if (isAm) {
                            _hour -= 12;
                          }
                        }
                        widget.handleDateChanged(DateTime(
                          widget.date.year,
                          widget.date.month,
                          widget.date.day,
                          _hour,
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
        Divider(style: DividerStyle(margin: (_) => EdgeInsets.zero)),
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
    );
  }
}
