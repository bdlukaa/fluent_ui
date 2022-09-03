import 'dart:math';

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/card_highlight.dart';

class ProgressIndicatorsPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Progress controls'));
  }

  double determinateValue = Random().nextDouble() * 100;

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      description(
        content: const Text(
          'A progress control provides feedback to the user that a long-running '
          'operation is underway. It can mean that the user cannot interact with '
          'the app when the progress indicator is visible, and can also indicate '
          'how long the wait time might be, depending on the indicator used.',
        ),
      ),
      subtitle(content: const Text('Indeterminate Progress Indicators')),
      description(
        content: const Text(
          'The indeterminate state shows that an operation is underway and its '
          'completion time is unknown.',
        ),
      ),
      CardHighlight(
        child: RepaintBoundary(
          child: Row(children: const [
            ProgressBar(),
            SizedBox(width: 20.0),
            ProgressRing(),
          ]),
        ),
        codeSnippet: '''// indeterminate progress bar
ProgressBar(),

// indeterminate progress ring
ProgressRing(),''',
      ),
      subtitle(content: const Text('Determinate Progress Indicators')),
      description(
        content: const Text(
          'The determinate state shows the percentage completed of a task. '
          'This should be used during an operation whose duration is known, but '
          'its progress should not block the user\'s interaction with the app.',
        ),
      ),
      CardHighlight(
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
          codeSnippet: '''// determinate progress bar
ProgressBar(value: ${determinateValue.toInt()}),

// determinate progress ring
ProgressRing(value: ${determinateValue.toInt()}),'''),
    ];
  }
}
