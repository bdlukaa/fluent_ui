import 'package:example/widgets/card_highlight.dart';
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TimePicker')),
      children: [
        const Text(
          'Use a TimePicker to let users set a time in your app, for example to '
          'set a reminder. The TimePicker displays three controls for hour, '
          'minute, and AM/PM. These controls are easy to use with touch or mouse, '
          'and they can be styled and configured in several different ways.\n\n'
          'The entry point displays the chosen time, and when the user selects '
          'the entry point, a picker surface expands vertically from the middle '
          'for the user to make a selection. The time picker overlays other UI; '
          'it doesn\'t push other UI out of the way.',
        ),
        subtitle(content: const Text('A simple TimePicker')),
        CardHighlight(
          codeSnippet: '''DateTime? selected;

TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TimePicker(
              selected: simpleTime,
              onChanged: (time) => setState(() => simpleTime = time),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'A TimePicker with a header and minute increments specified',
          ),
        ),
        CardHighlight(
          codeSnippet: '''DateTime? selected;
        
TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  header: 'Arrival time',
  minuteIncrement: 15,
),''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TimePicker(
              header: 'Arrival time',
              selected: arrivalTime,
              onChanged: (time) => setState(() => arrivalTime = time),
              minuteIncrement: 15,
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'A TimePicker using a 24-hour clock',
          ),
        ),
        CardHighlight(
          codeSnippet: '''DateTime? selected;
        
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
              onChanged: (v) => setState(() => hhTime = v),
              hourFormat: HourFormat.HH,
            ),
          ),
        ),
      ],
    );
  }
}
