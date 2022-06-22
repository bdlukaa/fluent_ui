import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ProgressIndicatorsPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('ProgressBar and ProgressRing'));
  }

  double determinateValue = 1.0;

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The progress indicators have two different visual representations:\nIndeterminate - shows that a task is ongoing, but blocks user interaction.\nDeterminate - shows how much progress has been made on a known amount of work.',
      ),
      subtitle(content: const Text('Indeterminate Progress Indicators')),
      Card(
        child: RepaintBoundary(
          child: Row(children: const [
            ProgressBar(),
            SizedBox(width: 20.0),
            ProgressRing(),
          ]),
        ),
      ),
      subtitle(content: const Text('Determinate Progress Indicators')),
      Card(
        child: Row(children: [
          ProgressBar(value: determinateValue),
          const SizedBox(width: 20.0),
          ProgressRing(value: determinateValue),
          const Spacer(),
          InfoLabel(
            label: 'Progress: ${determinateValue.toInt()}',
            child: Slider(
              value: determinateValue,
              onChanged: (v) => setState(() => determinateValue = v),
            ),
          ),
        ]),
      ),
    ];
  }
}
