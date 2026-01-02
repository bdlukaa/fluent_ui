import 'package:example/widgets/code_snippet_card.dart';
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

  final datePickerKey = GlobalKey<DatePickerState>();

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('DatePicker'),
        commandBar: Button(
          onPressed: () =>
              setState(() => simpleTime = hiddenTime = flexTime = null),
          child: const Text('Clear'),
        ),
      ),
      children: [
        const Text(
          'Use a DatePicker to let users set a date in your app, for example to '
          'schedule an appointment. The DatePicker displays three controls for '
          'month, date, and year. These controls are easy to use with touch or '
          'mouse, and they can be styled and configured in several different ways.'
          '\n\nThe entry point displays the chosen date, and when the user '
          'selects the entry point, a picker surface expands vertically from the '
          'middle for the user to make a selection. The date picker overlays '
          "other UI; it doesn't push other UI out of the way.",
        ),
        subtitle(content: const Text('A simple DatePicker with a header')),
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;

DatePicker(
  header: 'Pick a date',
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              children: [
                DatePicker(
                  header: 'Pick a date',
                  selected: simpleTime,
                  onChanged: (final time) => setState(() => simpleTime = time),
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
                        onChanged: (final v) => setState(() => showYear = v!),
                        content: const Text('Show year'),
                      ),
                      const SizedBox(height: 10),
                      Checkbox(
                        checked: showMonth,
                        onChanged: (final v) => setState(() => showMonth = v!),
                        content: const Text('Show month'),
                      ),
                      const SizedBox(height: 10),
                      Checkbox(
                        checked: showDay,
                        onChanged: (final v) => setState(() => showDay = v!),
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
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;

DatePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  showYear: false,
),''',
          child: Row(
            children: [
              DatePicker(
                key: datePickerKey,
                selected: hiddenTime,
                onChanged: (final v) => setState(() => hiddenTime = v),
                showYear: false,
              ),
              const Spacer(),
              Button(
                onPressed: () => datePickerKey.currentState?.open(),
                child: const Text('Show picker'),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A DatePicker with flex layout')),
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;

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
              onChanged: (final v) => setState(() => flexTime = v),
            ),
          ),
        ),
      ],
    );
  }
}
