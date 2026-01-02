import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TimePickerPage extends StatefulWidget {
  const TimePickerPage({super.key});

  @override
  State<TimePickerPage> createState() => _TimePickerPageState();
}

class _TimePickerPageState extends State<TimePickerPage> with PageMixin {
  DateTime? simpleTime;
  DateTime? arrivalTime;
  DateTime? hhTime;

  final timePickerKey = GlobalKey<TimePickerState>();

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('TimePicker'),
        commandBar: Button(
          onPressed: () =>
              setState(() => simpleTime = arrivalTime = hhTime = null),
          child: const Text('Clear'),
        ),
      ),
      children: [
        const Text(
          'Use a TimePicker to let users set a time in your app, for example to '
          'set a reminder. The TimePicker displays three controls for hour, '
          'minute, and AM/PM. These controls are easy to use with touch or mouse, '
          'and they can be styled and configured in several different ways.\n\n'
          'The entry point displays the chosen time, and when the user selects '
          'the entry point, a picker surface expands vertically from the middle '
          'for the user to make a selection. The time picker overlays other UI; '
          "it doesn't push other UI out of the way.",
        ),
        subtitle(content: const Text('A simple TimePicker')),
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;

TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
          child: Row(
            children: [
              TimePicker(
                key: timePickerKey,
                selected: simpleTime,
                onChanged: (final time) => setState(() => simpleTime = time),
              ),
              const Spacer(),
              Button(
                onPressed: () => timePickerKey.currentState?.open(),
                child: const Text('Show picker'),
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'A TimePicker with a header and minute increments specified',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;
        
TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  header: 'Arrival time',
  minuteIncrement: 15,
),''',
          child: Row(
            children: [
              TimePicker(
                header: 'Arrival time',
                selected: arrivalTime,
                onChanged: (final time) => setState(() => arrivalTime = time),
                minuteIncrement: 15,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A TimePicker using a 24-hour clock')),
        CodeSnippetCard(
          codeSnippet: '''
DateTime? selected;
        
TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  header: '24 hour clock',
  hourFormat: HourFormat.HH,
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TimePicker(
              header: '24 hour clock',
              selected: hhTime,
              onChanged: (final v) => setState(() => hhTime = v),
              hourFormat: HourFormat.HH,
            ),
          ),
        ),
      ],
    );
  }
}
