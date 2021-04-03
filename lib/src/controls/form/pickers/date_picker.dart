import 'package:fluent_ui/fluent_ui.dart';

import 'package:fluent_ui/src/utils/popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'pickers.dart';

// There is a known issue with clicking in the popup and select the date.
// The current workaround is very hacky and doesn't work very well with the
// current implementation. TODO: Fix clicking on ListWheelScrollView
// https://github.com/flutter/flutter/issues/38803

class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.header,
    this.headerStyle,
    this.showDay = true,
    this.showMonth = true,
    this.showYear = true,
    this.startYear,
    this.endYear,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPopupHeight,
    this.cursor = SystemMouseCursors.click,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  final DateTime selected;
  final ValueChanged<DateTime>? onChanged;
  final VoidCallback? onCancel;

  final String? header;
  final TextStyle? headerStyle;

  final bool showMonth;
  final bool showDay;
  final bool showYear;

  final int? startYear;
  final int? endYear;

  final EdgeInsetsGeometry contentPadding;
  final MouseCursor cursor;
  final FocusNode? focusNode;
  final bool autofocus;

  final double popupHeight;

  @override
  _DatePickerState createState() => _DatePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('selected', selected));
    properties.add(FlagProperty('showMonth', value: showMonth));
    properties.add(FlagProperty('showDay', value: showDay));
    properties.add(FlagProperty('showYear', value: showYear));
    properties.add(IntProperty('startYear', startYear ?? selected.year - 100));
    properties.add(IntProperty('endYear', endYear ?? selected.year + 25));
    properties.add(DiagnosticsProperty('contentPadding', contentPadding));
    properties.add(DiagnosticsProperty('cursor', cursor));
    properties.add(ObjectFlagProperty.has('focusNode', focusNode));
    properties.add(FlagProperty('autofocus', value: autofocus));
    properties.add(DoubleProperty('popupHeight', popupHeight));
  }
}

class _DatePickerState extends State<DatePicker> {
  late DateTime date;
  final popupKey = GlobalKey<PopUpState>();

  FixedExtentScrollController? _monthController;
  FixedExtentScrollController? _dayController;
  FixedExtentScrollController? _yearController;

  int get startYear => (widget.startYear ?? DateTime.now().year - 100).toInt();
  int get endYear => (widget.endYear ?? DateTime.now().year + 25).toInt();

  int get currentYear {
    return List.generate(endYear - startYear, (index) {
      return startYear + index;
    }).firstWhere((v) => v == date.year, orElse: () => 0);
  }

  @override
  void initState() {
    super.initState();
    date = widget.selected;
    initControllers();
  }

  void initControllers() {
    _monthController = FixedExtentScrollController(
      initialItem: date.month - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: date.day - 1,
    );

    _yearController = FixedExtentScrollController(
      initialItem: currentYear - startYear - 1,
    );
  }

  @override
  void dispose() {
    _monthController?.dispose();
    _dayController?.dispose();
    _yearController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != date) {
      date = widget.selected;
      _monthController?.jumpToItem(date.month - 1);
      _dayController?.jumpToItem(date.day - 1);
      _yearController?.jumpToItem(currentYear - startYear - 1);
    }
  }

  void handleDateChanged(DateTime newDate) {
    setState(() => date = newDate);
  }

  Size? size;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    Widget picker = HoverButton(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      cursor: (_) => widget.cursor,
      onPressed: () async {
        await popupKey.currentState?.openPopup();
        _monthController?.dispose();
        _monthController = null;
        _dayController?.dispose();
        _dayController = null;
        _yearController?.dispose();
        _yearController = null;
        initControllers();
      },
      builder: (context, state) {
        if (state == ButtonStates.disabled) state = ButtonStates.none;
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
            if (widget.showMonth)
              Expanded(
                flex: 2,
                child: () {
                  // MONTH
                  return Padding(
                    padding: widget.contentPadding,
                    child: Text(DateFormat.MMMM().format(widget.selected)),
                  );
                }(),
              ),
            if (widget.showDay) ...[
              divider,
              Expanded(
                child: () {
                  // DAY
                  return Padding(
                    padding: widget.contentPadding,
                    child: Text(
                      '${widget.selected.day}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }(),
              ),
            ],
            if (widget.showYear) ...[
              divider,
              Expanded(
                child: () {
                  // YEAR
                  return Padding(
                    padding: widget.contentPadding,
                    child: Text(
                      '${widget.selected.year}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }(),
              ),
            ],
          ]),
        );
      },
    );
    picker = PopUp(
      contentHeight: widget.popupHeight,
      key: popupKey,
      child: picker,
      content: (context) => _DatePickerContentPopUp(
        height: widget.popupHeight,
        date: date,
        dayController: _dayController!,
        endYear: endYear,
        handleDateChanged: handleDateChanged,
        monthController: _monthController!,
        onCancel: () => widget.onCancel?.call(),
        onChanged: () => widget.onChanged?.call(date),
        showDay: widget.showDay,
        showMonth: widget.showMonth,
        showYear: widget.showYear,
        startYear: startYear,
        yearController: _yearController!,
      ),
    );
    if (widget.header != null)
      return InfoHeader(
        header: widget.header!,
        headerStyle: widget.headerStyle,
        child: picker,
      );
    return picker;
  }
}

class _DatePickerContentPopUp extends StatefulWidget {
  const _DatePickerContentPopUp({
    Key? key,
    required this.showMonth,
    required this.showDay,
    required this.showYear,
    required this.date,
    required this.handleDateChanged,
    required this.onChanged,
    required this.onCancel,
    required this.monthController,
    required this.dayController,
    required this.yearController,
    required this.startYear,
    required this.endYear,
    required this.height,
  }) : super(key: key);

  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final DateTime date;
  final ValueChanged<DateTime> handleDateChanged;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController dayController;
  final FixedExtentScrollController yearController;
  final int startYear;
  final int endYear;
  final double height;

  @override
  __DatePickerContentPopUpState createState() =>
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

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final divider = Divider(
      direction: Axis.vertical,
      style: DividerStyle(margin: (_) => EdgeInsets.zero),
    );
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
              if (widget.showMonth)
                Expanded(
                  flex: 2,
                  child: () {
                    final items = List.generate(
                      12,
                      (index) {
                        final text = DateFormat.MMMM().format(
                          DateTime(1, index + 1),
                        );
                        return ListTile(
                          title: Text(
                            text,
                            style: kPickerPopupTextStyle(context),
                          ),
                        );
                      },
                    );
                    // MONTH
                    return PickerNavigatorIndicator(
                      onBackward: () {
                        navigateSides(
                          context,
                          widget.monthController,
                          false,
                          12,
                        );
                      },
                      onForward: () {
                        navigateSides(
                          context,
                          widget.monthController,
                          true,
                          12,
                        );
                      },
                      child: ListWheelScrollView.useDelegate(
                        controller: widget.monthController,
                        itemExtent: kOneLineTileHeight,
                        diameterRatio: kPickerDiameterRatio,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: items,
                        ),
                        onSelectedItemChanged: (index) {
                          final month = index + 1;
                          final daysInMonth =
                              _getDaysInMonth(month, widget.date.year);
                          int day = widget.date.day;
                          if (day > daysInMonth) day = daysInMonth;
                          widget.handleDateChanged(DateTime(
                            widget.date.year,
                            month,
                            day,
                            widget.date.hour,
                            widget.date.minute,
                            widget.date.second,
                            widget.date.millisecond,
                            widget.date.microsecond,
                          ));
                          setState(() {});
                        },
                      ),
                    );
                  }(),
                ),
              if (widget.showDay) ...[
                divider,
                Expanded(
                  child: () {
                    // DAY
                    final daysInMonth =
                        _getDaysInMonth(widget.date.month, widget.date.year);
                    return PickerNavigatorIndicator(
                      onBackward: () {
                        navigateSides(
                          context,
                          widget.dayController,
                          false,
                          daysInMonth,
                        );
                      },
                      onForward: () {
                        navigateSides(
                          context,
                          widget.dayController,
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
                          children: List<Widget>.generate(
                            daysInMonth,
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
                        onSelectedItemChanged: (index) {
                          widget.handleDateChanged(DateTime(
                            widget.date.year,
                            widget.date.month,
                            index + 1,
                            widget.date.hour,
                            widget.date.minute,
                            widget.date.second,
                            widget.date.millisecond,
                            widget.date.microsecond,
                          ));
                        },
                      ),
                    );
                  }(),
                ),
              ],
              if (widget.showYear) ...[
                divider,
                Expanded(
                  child: () {
                    final years = widget.endYear - widget.startYear;
                    // YEAR
                    return PickerNavigatorIndicator(
                      onBackward: () {
                        navigateSides(
                          context,
                          widget.yearController,
                          false,
                          years,
                        );
                      },
                      onForward: () {
                        navigateSides(
                          context,
                          widget.yearController,
                          true,
                          years,
                        );
                      },
                      child: ListWheelScrollView(
                        controller: widget.yearController,
                        children: List.generate(years, (index) {
                          return ListTile(
                            title: Center(
                              child: Text(
                                '${widget.startYear + index + 1}',
                                style: kPickerPopupTextStyle(context),
                              ),
                            ),
                          );
                        }),
                        itemExtent: kOneLineTileHeight,
                        diameterRatio: kPickerDiameterRatio,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          widget.handleDateChanged(DateTime(
                            widget.startYear + index + 1,
                            widget.date.month,
                            widget.date.day,
                            widget.date.hour,
                            widget.date.minute,
                            widget.date.second,
                            widget.date.millisecond,
                            widget.date.microsecond,
                          ));
                        },
                      ),
                    );
                  }(),
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
