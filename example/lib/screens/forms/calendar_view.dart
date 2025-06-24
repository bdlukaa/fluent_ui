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
  bool groupLabelVisible = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('CalendarView'),
        commandBar: Button(
          onPressed: () => setState(
            () => outOfScopeEnabled =
                todayHighlighted = groupLabelVisible = false,
          ),
          child: const Text('Clear'),
        ),
      ),
      children: [
        const Text(
          'Use a CalendarView to let users select one or more dates directly from a calendar grid. '
          'CalendarView displays a monthly calendar, allowing users to tap or click on specific days to select them. '
          'You can configure the selection mode to allow single, multiple, or range selections, depending on your app’s needs.\n\n'
          'The calendar highlights the selected date(s) and can be customized to indicate today’s date or out-of-scope dates. '
          'CalendarView provides an intuitive and familiar way for users to pick dates, making it ideal for scheduling, booking, or planning features. '
          'Selections are updated instantly as users interact with the calendar, and you can respond to changes through callbacks in your app.',
        ),
        subtitle(content: const Text('Default CalendarView')),
        CardHighlight(
          codeSnippet: '''CalendarView(
  selectionMode: $selectionMode,
  onSelectionChanged: (value) {
    debugPrint('\${value.selectedDates}');
  },
);
''',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarView(
                selectionMode: selectionMode,
                onSelectionChanged: (value) {
                  debugPrint('${value.selectedDates}');
                },
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
          codeSnippet: '''
CalendarView(
  isOutOfScopeEnabled: false, // By default
  isTodayHighlighted: true,
  isGroupLabelVisible: true,
),''',
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 350,
                  child: CalendarView(
                    isOutOfScopeEnabled: outOfScopeEnabled,
                    isTodayHighlighted: todayHighlighted,
                    isGroupLabelVisible: groupLabelVisible,
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
                        checked: groupLabelVisible,
                        onChanged: (v) =>
                            setState(() => groupLabelVisible = v!),
                        content: const Text('Group Label visible'),
                      ),
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
