import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TimePickerPage extends ScrollablePage {
  PageState state = {
    'simple_time': null,
    'arrival_time': null,
    '24_time': null,
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
      Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: TimePicker(
              selected: state['simple_time'],
              onChanged: (time) => setState(() => state['simple_time'] = time),
            ),
          ),
        ),
      ),
      subtitle(
        content: const Text(
          'A TimePicker with a header and minute increments specified',
        ),
      ),
      Card(
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
      ),
      subtitle(
        content: const Text(
          'A TimePicker using a 24-hour clock',
        ),
      ),
      Card(
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
      ),
    ];
  }
}
