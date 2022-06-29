import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TimePickerPage extends ScrollablePage {
  PageState state = {
    'simple_time': DateTime.now(),
    'arrival_time': DateTime.now(),
    '24_time': DateTime.now(),
  };

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TimePicker'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use a TimePicker to let users set a time in your app, for example to set a reminder. The TimePicker displays three controls for hour, minute, and AM/PM. These controls are easy to use with touch or mouse, and they can be styled and configured in several different ways.',
      ),
      subtitle(content: const Text('A simple TimePicker')),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: TimePicker(
              selected: state['simple_time'],
              onChanged: (time) => setState(() => state['simple_tile'] = time),
            ),
          ),
        ),
        codeSnippet: '''DateTime? selected;

TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
),''',
      ),
      subtitle(
        content: const Text(
          'A TimePicker with a header and minute increments specified',
        ),
      ),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: TimePicker(
              header: 'Arrival time',
              selected: state['arrival_time'],
              onChanged: (time) => setState(() => state['arrival_time'] = time),
              minuteIncrement: 15,
            ),
          ),
        ),
        codeSnippet: '''DateTime? selected;
        
TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  header: 'Arrival time',
  minuteIncrement: 15,
),''',
      ),
      subtitle(
        content: const Text(
          'A TimePicker using a 24-hour clock',
        ),
      ),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: TimePicker(
              header: '24 hour clock',
              selected: state['24_time'],
              onChanged: (v) => setState(() => state['24_time'] = v),
              hourFormat: HourFormat.HH,
            ),
          ),
        ),
        codeSnippet: '''DateTime? selected;
        
TimePicker(
  selected: selected,
  onChanged: (time) => setState(() => selected = time),
  header: '24 hour clock',
  hourFormat: HourFormat.HH,
),''',
      ),
    ];
  }
}
