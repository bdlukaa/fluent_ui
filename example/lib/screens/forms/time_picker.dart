import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TimePickerPage extends ScrollablePage {
  DateTime? simpleTime;
  DateTime? arrivalTime;
  DateTime? hhTime;

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
      Card(
        child: Align(
          alignment: Alignment.centerLeft,
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
      Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: TimePicker(
            header: '24 hour clock',
            selected: hhTime,
            onChanged: (v) => setState(() => hhTime = v),
            hourFormat: HourFormat.HH,
          ),
        ),
      ),
    ];
  }
}
