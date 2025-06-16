import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({super.key});

  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> with PageMixin {
  DateTimeRange? range;
  CalendarViewSelectionMode selectionMode = CalendarViewSelectionMode.single;

  bool outOfScopeEnabled = false;
  bool todayHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('CalendarView'),
        commandBar: Button(
          onPressed: () => setState(
            () => outOfScopeEnabled = todayHighlighted = false,
          ),
          child: const Text('Clear'),
        ),
      ),
      children: [
        const Text(
          'Use a DateRangePicker to let users select a start and end date in your '
          'app, for example to book a hotel stay or plan a trip. The DateRangePicker '
          'displays two date fields—start and end—each with controls for month, '
          'date, and year. These controls are intuitive and offer styling and '
          'configuration options to match your app’s design.\n\nThe entry point '
          'shows the currently selected range, and when the user taps or clicks '
          'it, a dialog appears containing two DatePickers —one for selecting the '
          'start date and another for the end date. This dialog provides a focused'
          ', modal experience where users can easily choose a date range without '
          'distractions. Once the range is selected, the dialog closes and the '
          'chosen dates are reflected in the entry fields.',
        ),
        subtitle(content: const Text('Default CalendarView')),
        CardHighlight(
          codeSnippet: 'CalendarView();',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: CalendarView(
                  selectionMode: selectionMode,
                ),
              ),
              SizedBox(
                width: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: CalendarViewSelectionMode.values.map(
                    (e) {
                      return RadioButton(
                        checked: e == selectionMode,
                        onChanged: (v) => setState(() => selectionMode = e),
                        content: Text(e.name.uppercaseFirst()),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A customized CalendarView')),
        CardHighlight(
          codeSnippet: '''DateTime? selected;

CalendarView(
  initialStart: selected,
  onSelectionChanged: (time) => setState(() => selected = time),
),''',
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 340,
                  child: CalendarView(
                    isOutOfScopeEnabled: outOfScopeEnabled,
                    isTodayHighlighted: todayHighlighted,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Checkbox(
                        checked: outOfScopeEnabled,
                        onChanged: (v) =>
                            setState(() => outOfScopeEnabled = v!),
                        content: const Text('Enable Out of scope'),
                      ),
                      Checkbox(
                        checked: todayHighlighted,
                        onChanged: (v) => setState(() => todayHighlighted = v!),
                        content: const Text('Highlight Today'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
