import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DatePickerPage extends ScrollablePage {
  PageState state = {
    'simple_time': null,
    'hidden_time': null,
  };

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('DatePicker'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use a DatePicker to let users set a date in your app, for example to schedule an appointment. The DatePicker displays three controls for month, date, and year. These controls are easy to use with touch or mouse, and they can be styled and configured in several different ways.',
      ),
      subtitle(content: const Text('A simple DatePicker with a header')),
      Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: DatePicker(
              header: 'Pick a date',
              selected: state['simple_time'],
              onChanged: (time) => setState(() => state['simple_time'] = time),
            ),
          ),
        ),
      ),
      subtitle(content: const Text('A DatePicker with year hidden')),
      Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240.0,
            child: DatePicker(
              selected: state['hidden_time'],
              onChanged: (v) => setState(() => state['hidden_time'] = v),
              showYear: false,
            ),
          ),
        ),
      ),
    ];
  }
}
