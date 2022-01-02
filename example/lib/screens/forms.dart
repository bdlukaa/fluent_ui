// ignore_for_file: avoid_print

import 'package:fluent_ui/fluent_ui.dart';

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
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Forms showcase')),
      content: ListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        children: [
          const TextBox(
            header: 'Email',
            placeholder: 'Type your email here :)',
          ),
          const SizedBox(height: 20),
          Row(children: [
            const Expanded(
              child: TextBox(
                readOnly: true,
                placeholder: 'Read only text box',
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
              child: AutoSuggestBox<String>(
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
          TextBox(
            maxLines: null,
            controller: _clearController,
            suffixMode: OverlayVisibilityMode.always,
            minHeight: 100,
            suffix: IconButton(
              icon:  const Icon(FluentIcons.chrome_close),
              onPressed: () {
                _clearController.clear();
              },
            ),
            placeholder: 'Text box with clear button',
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
          Mica(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(runSpacing: 8, children: [
                SizedBox(
                  width: 200,
                  child: InfoLabel(
                    label: 'Colors',
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
                const SizedBox(width: 12),
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
