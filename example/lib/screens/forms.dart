// ignore_for_file: avoid_print

import 'package:fluent_ui/fluent_ui.dart';

import 'package:email_validator/email_validator.dart';

class Forms extends StatefulWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  final _clearController = TextEditingController();
  bool _showPassword = false;

  static const values = <String>[
    'Red',
    'Yellow',
    'Green',
    'Cyan',
    'Blue',
    'Magenta',
    'Orange',
    'Violet',
    'Pink',
    'Brown',
    'Purple',
    'Gray',
    'Black',
    'White',
  ];
  String? comboBoxValue;

  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clearController.addListener(() {
      if (_clearController.text.length == 1 && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Forms showcase')),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextFormBox(
              header: 'Email',
              placeholder: 'Type your email here :)',
              autovalidateMode: AutovalidateMode.always,
              validator: (text) {
                if (text == null || text.isEmpty) return 'Provide an email';
                if (!EmailValidator.validate(text)) return 'Email not valid';
                return null;
              },
              textInputAction: TextInputAction.next,
              prefix: const Padding(
                padding: EdgeInsetsDirectional.only(start: 8.0),
                child: Icon(FluentIcons.edit_mail),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InfoLabel(
              label: 'Color',
              child: Combobox<String>(
                placeholder: const Text('Choose a color'),
                isExpanded: true,
                items: values
                    .map((e) => ComboboxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                value: comboBoxValue,
                onChanged: (value) {
                  print(value);
                  if (value != null) {
                    setState(() => comboBoxValue = value);
                  }
                },
              ),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextBox(
              readOnly: true,
              placeholder: 'Read only text box',
              highlightColor: Colors.magenta,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: TextBox(
              enabled: false,
              placeholder: 'Disabled text box',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSuggestBox.form(
              autovalidateMode: AutovalidateMode.always,
              validator: (t) {
                if (t == null || t.isEmpty) return 'emtpy';

                return null;
              },
              items: values,
              placeholder: 'Pick a color',
              trailingIcon: IconButton(
                icon: const Icon(FluentIcons.search),
                onPressed: () {
                  debugPrint('trailing button pressed');
                },
              ),
              onSelected: (text) {
                print(text);
              },
            ),
          ),
        ]),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: TextFormBox(
            maxLines: null,
            controller: _clearController,
            suffixMode: OverlayVisibilityMode.always,
            minHeight: 100,
            expands: true,
            suffix: _clearController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(FluentIcons.chrome_close),
                    onPressed: () {
                      _clearController.clear();
                    },
                  ),
            placeholder: 'Text box with clear button',
          ),
        ),
        const SizedBox(height: 20),
        TextBox(
          header: 'Password',
          placeholder: 'Type your placeholder here',
          obscureText: !_showPassword,
          maxLines: 1,
          suffixMode: OverlayVisibilityMode.always,
          suffix: IconButton(
            icon: Icon(
              !_showPassword ? FluentIcons.lock : FluentIcons.unlock,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          outsideSuffix: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Button(
              child: const Text('Done'),
              onPressed: () {},
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Wrap(runSpacing: 8, children: [
            SizedBox(
              width: 295,
              child: DatePicker(
                // popupHeight: kOneLineTileHeight * 6,
                header: 'Date of birth',
                selected: date,
                onChanged: (v) => setState(() => date = v),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 240,
              child: TimePicker(
                // popupHeight: kOneLineTileHeight * 5,
                header: 'Arrival time',
                selected: date,
                onChanged: (v) => setState(() => date = v),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        InfoLabel(
          label: 'Selectable Text',
          child: Card(
            child: SelectableText(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              selectionControls: fluentTextSelectionControls,
              showCursor: true,
              cursorWidth: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
