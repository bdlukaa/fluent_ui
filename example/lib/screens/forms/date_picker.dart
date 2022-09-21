import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({Key? key}) : super(key: key);

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> with PageMixin {
  DateTime? simpleTime;
  DateTime? hiddenTime;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('DatePicker')),
      children: [
        const Text(
          'Use a DatePicker to let users set a date in your app, for example to '
          'schedule an appointment. The DatePicker displays three controls for '
          'month, date, and year. These controls are easy to use with touch or '
          'mouse, and they can be styled and configured in several different ways.'
          '\n\nThe entry point displays the chosen date, and when the user '
          'selects the entry point, a picker surface expands vertically from the '
          'middle for the user to make a selection. The date picker overlays '
          'other UI; it doesn\'t push other UI out of the way.',
        ),
        subtitle(content: const Text('A simple DatePicker with a header')),
        CardHighlight(
          child: Align(
            alignment: Alignment.centerLeft,
            child: DatePicker(
              header: 'Pick a date',
              selected: simpleTime,
              onChanged: (time) => setState(() => simpleTime = time),
            ),
          ),
          codeSnippet: '''DateTime? selected;

DatePicker(
  header: 'Pick a date',
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
        ),
        subtitle(content: const Text('A DatePicker with year hidden')),
        CardHighlight(
          child: Align(
            alignment: Alignment.centerLeft,
            child: DatePicker(
              selected: hiddenTime,
              onChanged: (v) => setState(() => hiddenTime = v),
              showYear: false,
            ),
          ),
          codeSnippet: '''DateTime? selected;

DatePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  showYear: false,
),''',
        ),
      ],
    );
  }
}
