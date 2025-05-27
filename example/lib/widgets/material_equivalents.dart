import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' as c;
import 'package:flutter/material.dart' as m;

class UIEquivalents extends StatefulWidget {
  const UIEquivalents({super.key});

  @override
  State<UIEquivalents> createState() => _UIEquivalentsState();
}

class _UIEquivalentsState extends State<UIEquivalents> {
  bool comboboxChecked = true;
  bool radioChecked = true;
  bool switchChecked = true;

  final List<String> comboboxItems = [
    'Item 1',
    'Item 2',
  ];
  String? comboboxItem;
  String dropdownItem = 'Item 1';
  final popupKey = GlobalKey<m.PopupMenuButtonState>();

  double sliderValue = Random().nextDouble() * 100;

  final fieldController = TextEditingController();
  DateTime time = DateTime.now();

  @override
  void dispose() {
    fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> children = [
      [
        const Text('Button'),
        Button(
          child: const Text('Content'),
          onPressed: () {},
        ),
        m.OutlinedButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
        c.CupertinoButton.tinted(
          child: const Text('Content'),
          onPressed: () {},
        ),
      ],
      [
        const Text('HyperlinkButton'),
        HyperlinkButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
        m.TextButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
        c.CupertinoButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
      ],
      [
        const Text('FilledButton'),
        FilledButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
        m.ElevatedButton(
          child: const Text('Content'),
          onPressed: () {},
        ),
        c.CupertinoButton.filled(
          child: const Text('Content'),
          onPressed: () {},
        ),
      ],
      [
        const Text('IconButton'),
        IconButton(
          icon: const Icon(FluentIcons.graph_symbol),
          onPressed: () {},
        ),
        m.IconButton(
          icon: const Icon(FluentIcons.graph_symbol),
          onPressed: () {},
        ),
        // c.CupertinoNavigationBarBackButton(
        //   onPressed: () {},
        // ),
      ],
      [
        const Text('Checkbox'),
        Checkbox(
          checked: comboboxChecked,
          onChanged: (v) =>
              setState(() => comboboxChecked = v ?? comboboxChecked),
        ),
        m.Checkbox(
          value: comboboxChecked,
          onChanged: (v) =>
              setState(() => comboboxChecked = v ?? comboboxChecked),
        ),
        c.CupertinoCheckbox(
          value: comboboxChecked,
          onChanged: (v) =>
              setState(() => comboboxChecked = v ?? comboboxChecked),
        ),
      ],
      [
        const Text('RadioButton'),
        RadioButton(
          checked: radioChecked,
          onChanged: (v) => setState(() => radioChecked = v),
        ),
        m.Radio<bool>(
          groupValue: true,
          value: radioChecked,
          onChanged: (v) => setState(() => radioChecked = !radioChecked),
        ),
        c.CupertinoRadio(
          value: true,
          groupValue: radioChecked,
          onChanged: (v) => setState(() => radioChecked = !radioChecked),
        ),
      ],
      [
        const Text('ToggleSwitch'),
        ToggleSwitch(
          checked: switchChecked,
          onChanged: (v) => setState(() => switchChecked = v),
        ),
        m.Switch(
          value: switchChecked,
          onChanged: (v) => setState(() => switchChecked = v),
        ),
        c.CupertinoSwitch(
          value: switchChecked,
          onChanged: (v) => setState(() => switchChecked = v),
        ),
      ],
      [
        const Text('Slider'),
        Slider(
          value: sliderValue,
          max: 100,
          onChanged: (v) => setState(() => sliderValue = v),
        ),
        m.Slider(
          value: sliderValue,
          max: 100,
          onChanged: (v) => setState(() => sliderValue = v),
        ),
        c.CupertinoSlider(
          value: sliderValue,
          max: 100,
          onChanged: (v) => setState(() => sliderValue = v),
        ),
      ],
      [
        const Text('ProgressRing'),
        const RepaintBoundary(child: ProgressRing()),
        const RepaintBoundary(child: m.CircularProgressIndicator()),
        const RepaintBoundary(child: c.CupertinoActivityIndicator()),
      ],
      [
        const Text('ProgressBar'),
        const RepaintBoundary(child: ProgressBar()),
        const RepaintBoundary(child: m.LinearProgressIndicator()),
        const RepaintBoundary(child: c.CupertinoActivityIndicator()),
      ],
      [
        const Text('ComboBox'),
        ComboBox<String>(
          items: comboboxItems
              .map((e) => ComboBoxItem(value: e, child: Text(e)))
              .toList(),
          value: comboboxItem,
          onChanged: (value) => setState(() => comboboxItem = value),
        ),
        m.DropdownButton<String>(
          items: comboboxItems
              .map((e) => m.DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: comboboxItem,
          onChanged: (value) => setState(() => comboboxItem = value),
        ),
        c.CupertinoPicker(
          itemExtent: 32.0,
          onSelectedItemChanged: (value) =>
              setState(() => comboboxItem = comboboxItems[value]),
          children: comboboxItems.map((e) => c.Text(e)).toList(),
        ),
      ],
      [
        const Text('DropDownButton'),
        DropDownButton(
          items: comboboxItems
              .map(
                (e) => MenuFlyoutItem(
                  text: Text(e),
                  onPressed: () => setState(() => dropdownItem = e),
                ),
              )
              .toList(),
          title: Text(dropdownItem),
        ),
        m.PopupMenuButton<String>(
          key: popupKey,
          itemBuilder: (context) {
            return comboboxItems
                .map(
                  (e) => m.PopupMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList();
          },
          onSelected: (e) => setState(() => dropdownItem = e),
          initialValue: dropdownItem,
          position: m.PopupMenuPosition.under,
          child: m.TextButton(
            child: Text(dropdownItem),
            onPressed: () {
              popupKey.currentState?.showButtonMenu();
            },
          ),
        ),
        c.CupertinoButton(
          child: Text(dropdownItem),
          onPressed: () {
            c.showCupertinoModalPopup(
              context: context,
              builder: (context) => c.CupertinoActionSheet(
                actions: comboboxItems
                    .map(
                      (e) => c.CupertinoActionSheetAction(
                        child: c.Text(e),
                        onPressed: () => setState(() => dropdownItem = e),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
      [
        const Text('TextBox'),
        TextBox(controller: fieldController),
        m.TextField(controller: fieldController),
        c.CupertinoTextField(
          controller: fieldController,
          style: const c.TextStyle(color: Colors.white),
        ),
      ],
      [
        const Text('TimePicker'),
        TimePicker(
          selected: time,
          onChanged: (value) => setState(() => time),
        ),
        m.TextButton(
          child: const Text('Show Picker'),
          onPressed: () async {
            final newTime = await m.showTimePicker(
              context: context,
              initialTime: m.TimeOfDay(
                hour: time.hour,
                minute: time.minute,
              ),
            );
            if (newTime != null) {
              time = DateTime(
                time.year,
                time.month,
                time.day,
                newTime.hour,
                newTime.minute,
                time.second,
              );
            }
          },
        ),
        c.CupertinoButton(
          child: const Text('Show Picker'),
          onPressed: () async {
            c.showCupertinoModalPopup(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    color:
                        c.CupertinoColors.systemBackground.resolveFrom(context),
                    child: SafeArea(
                      top: false,
                      child: c.CupertinoDatePicker(
                        initialDateTime: time,
                        mode: c.CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() => time = newDate);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
      [
        const Text('DatePicker'),
        DatePicker(
          selected: time,
          onChanged: (value) => setState(() => time),
        ),
        m.TextButton(
          child: const Text('Show Picker'),
          onPressed: () async {
            final newTime = await m.showDatePicker(
              context: context,
              initialDate: time,
              firstDate: DateTime(time.year - 100),
              lastDate: DateTime(time.year + 100),
            );
            if (newTime != null) {
              setState(() => time = newTime);
            }
          },
        ),
        c.CupertinoButton(
          child: const Text('Show Picker'),
          onPressed: () async {
            c.showCupertinoModalPopup(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    color:
                        c.CupertinoColors.systemBackground.resolveFrom(context),
                    child: SafeArea(
                      top: false,
                      child: c.CupertinoDatePicker(
                        initialDateTime: time,
                        mode: c.CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        showDayOfWeek: true,
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() => time = newDate);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
      [
        const Text('ListTile'),
        ListTile(
          leading: const Icon(FluentIcons.graph_symbol),
          title: const Text('Content'),
          onPressed: () {},
        ),
        m.ListTile(
          leading: const Icon(FluentIcons.graph_symbol),
          title: const Text('Content'),
          onTap: () {},
        ),
        c.CupertinoListTile(
          leading: const Icon(FluentIcons.graph_symbol),
          title: const Text('Content'),
          onTap: () {},
        ),
      ],
      [
        const Text('Tooltip'),
        const Tooltip(
          message: 'A fluent-styled tooltip',
          child: Text('Hover'),
        ),
        const m.Tooltip(
          message: 'A material-styled tooltip',
          child: Text('Hover'),
        ),
      ],
    ];

    Widget buildColumn(int index) {
      return FocusTraversalGroup(
        child: Column(
          children: children
              .map(
                (children) => Container(
                  constraints: const BoxConstraints(minHeight: 50.0),
                  alignment: AlignmentDirectional.center,
                  child: children.firstWhere(
                    (e) => children.indexOf(e) == index,
                    orElse: () => const SizedBox(),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    return m.Material(
      type: m.MaterialType.transparency,
      child: Row(children: [
        Expanded(child: buildColumn(0)),
        const m.VerticalDivider(),
        Expanded(child: buildColumn(1)),
        const m.VerticalDivider(),
        Expanded(child: buildColumn(2)),
        const m.VerticalDivider(),
        Expanded(child: buildColumn(3)),
      ]),
    );
  }
}
