import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> with PageMixin {
  DateTime? simpleTime;
  DateTime? hiddenTime;
  DateTime? flexTime;

  bool showYear = true;
  bool showMonth = true;
  bool showDay = true;

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
          codeSnippet: '''DateTime? selected;

DatePicker(
  header: 'Pick a date',
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceBetween,
              children: [
                DatePicker(
                  header: 'Pick a date',
                  selected: simpleTime,
                  onChanged: (time) => setState(() => simpleTime = time),
                  onCancel: () => debugPrint('User did not pick any date'),
                  showDay: showDay,
                  showMonth: showMonth,
                  showYear: showYear,
                ),
                SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        checked: showYear,
                        onChanged: (v) => setState(() => showYear = v!),
                        content: const Text('Show year'),
                      ),
                      const SizedBox(height: 10.0),
                      Checkbox(
                        checked: showMonth,
                        onChanged: (v) => setState(() => showMonth = v!),
                        content: const Text('Show month'),
                      ),
                      const SizedBox(height: 10.0),
                      Checkbox(
                        checked: showDay,
                        onChanged: (v) => setState(() => showDay = v!),
                        content: const Text('Show day'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        subtitle(content: const Text('A DatePicker with year hidden')),
        CardHighlight(
          codeSnippet: '''DateTime? selected;

DatePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  showYear: false,
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DatePicker(
              selected: hiddenTime,
              onChanged: (v) => setState(() => hiddenTime = v),
              showYear: false,
            ),
          ),
        ),
        subtitle(content: const Text('A DatePicker with flex layout')),
        CardHighlight(
          codeSnippet: '''DateTime? selected;

DatePicker(
  selected: selected,
  fieldFlex: const [2, 3, 2], // Same order as fieldOrder
  onChanged: (time) => setState(() => selected = time),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DatePicker(
              selected: flexTime,
              fieldFlex: const [2, 3, 2],
              onChanged: (v) => setState(() => flexTime = v),
            ),
          ),
        ),
      ],
    );
  }
}
